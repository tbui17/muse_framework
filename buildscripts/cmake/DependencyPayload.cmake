# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Reviewed, verifiable dependency payload engine.
#
# Three locations are kept deliberately separate:
#
#   * recipe code:  buildscripts/cmake/deps/<name>.cmake  (checked in, never downloaded)
#   * payload pins: buildscripts/cmake/deps/dependencies.lock.cmake (checked in URLs + SHA-256)
#   * payloads:     one directory per dependency under FETCHCONTENT_BASE_DIR (the build tree)
#
# A dependency directory counts as complete only when its reviewed layout exists AND it records
# the payload hashes that produced it, and each cached archive is re-verified against its pin
# before the directory is reused. A changed dependencies.lock.cmake therefore invalidates the
# extracted tree instead of silently keeping the previous dependency.
#
# No remote response is trusted: every payload is downloaded/staged to a temporary file,
# checked against the pinned SHA-256, atomically promoted, extracted into a staging
# directory, and only then moved into place. A dependency is considered populated only
# when its expected layout exists, and it is validated per dependency.
#
# TLS verification is never disabled here. Remote downloads go through file(DOWNLOAD), which
# only verifies the server certificate when CMAKE_TLS_VERIFY is set; this engine sets it to ON
# for the download scope and refuses to run at all when an operator has globally disabled it.

# This file is deliberately idempotent (no include_guard): it may be included from several
# directory scopes, and the pinned lock variables must be visible in each of them.
set(MUSE_DEPS_RECIPE_DIR "${CMAKE_CURRENT_LIST_DIR}/deps" CACHE PATH
    "Directory holding the reviewed, checked-in dependency recipes")
set(MUSE_DEPENDENCY_DOWNLOAD_ATTEMPTS "3" CACHE STRING
    "Number of attempts per pinned dependency payload download")

include("${CMAKE_CURRENT_LIST_DIR}/deps/dependencies.lock.cmake")

# Read MUSE_DEP_<name>_<key> without failing when it is not pinned.
function(muse_dependency_lock_get name key out_var)
    set(_lock_var "MUSE_DEP_${name}_${key}")
    if (NOT DEFINED ${_lock_var})
        set(${out_var} "" PARENT_SCOPE)
        return()
    endif()
    set(${out_var} "${${_lock_var}}" PARENT_SCOPE)
endfunction()

# Output directory for one dependency's payloads, under the build tree.
#
# The framework is included from the application's early setup, before the application assigns
# FETCHCONTENT_BASE_DIR, and a standalone build may leave it to FetchContent. Fall back to the
# same "<binary dir>/_deps" location the application configures, instead of failing on include
# order; the explicit variable still wins when it is set.
function(muse_dependency_output_dir name out_var)
    if (DEFINED FETCHCONTENT_BASE_DIR AND NOT FETCHCONTENT_BASE_DIR STREQUAL "")
        set(_base_dir "${FETCHCONTENT_BASE_DIR}")
    elseif (DEFINED PROJECT_BINARY_DIR AND NOT PROJECT_BINARY_DIR STREQUAL "")
        set(_base_dir "${PROJECT_BINARY_DIR}/_deps")
    else()
        message(FATAL_ERROR
            "[deps] neither FETCHCONTENT_BASE_DIR nor PROJECT_BINARY_DIR is set; the dependency payload output directory cannot be resolved")
    endif()
    set(${out_var} "${_base_dir}/${name}" PARENT_SCOPE)
endfunction()

# Set <out_ok> TRUE when <payload_file> exists and its SHA-256 equals <expected_sha256>.
function(muse_dependency_verify_hash payload_file expected_sha256 out_ok)
    if (NOT EXISTS "${payload_file}")
        set(${out_ok} FALSE PARENT_SCOPE)
        return()
    endif()

    file(SHA256 "${payload_file}" _actual_sha256)
    string(TOLOWER "${expected_sha256}" _expected)
    string(TOLOWER "${_actual_sha256}" _actual)
    if (_actual STREQUAL _expected)
        set(${out_ok} TRUE PARENT_SCOPE)
    else()
        set(${out_ok} FALSE PARENT_SCOPE)
    endif()
endfunction()

# Fetch one pinned payload to <archive_path>, verifying its SHA-256 before promoting it.
# An already present file is re-verified instead of trusted. A failed temporary download is
# removed before retrying, so a partial payload can never be reused.
function(muse_dependency_fetch_payload name url expected_sha256 archive_path)
    set(_verified FALSE)
    muse_dependency_verify_hash("${archive_path}" "${expected_sha256}" _verified)
    if (_verified)
        message(STATUS "[${name}] reusing verified payload ${archive_path}")
        return()
    endif()

    if (NOT url MATCHES "^file://" AND DEFINED CMAKE_TLS_VERIFY AND NOT CMAKE_TLS_VERIFY)
        message(FATAL_ERROR
            "[${name}] CMAKE_TLS_VERIFY is OFF, so pinned payload downloads would not verify certificates. "
            "Re-enable it (-DCMAKE_TLS_VERIFY=ON) or point EXTDEPS-style mirrors at a trusted location instead.")
    endif()

    get_filename_component(_archive_dir "${archive_path}" DIRECTORY)
    file(MAKE_DIRECTORY "${_archive_dir}")

    string(RANDOM LENGTH 8 ALPHABET "0123456789abcdef" _nonce)
    set(_temp_path "${archive_path}.part-${_nonce}")

    if (url MATCHES "^file://")
        # Local mirror (offline/air-gapped preparation). Pinned URL and hash still apply.
        string(LENGTH "file://" _scheme_length)
        string(SUBSTRING "${url}" ${_scheme_length} -1 _source_path)
        if (NOT EXISTS "${_source_path}")
            message(FATAL_ERROR "[${name}] pinned payload source does not exist: ${url}")
        endif()
        file(COPY_FILE "${_source_path}" "${_temp_path}")
    else()
        file(MAKE_DIRECTORY "${_archive_dir}")
        # Certificate verification is explicit: file(DOWNLOAD) verifies the server
        # certificate only when CMAKE_TLS_VERIFY is set. The variable form is used rather than
        # a per-command option so the engine works with the CMake versions the builders have;
        # setting it in this function scope keeps downloads verified without leaking it out.
        set(CMAKE_TLS_VERIFY ON)
        set(_attempt "1")
        set(_downloaded FALSE)
        while (_attempt LESS_EQUAL "${MUSE_DEPENDENCY_DOWNLOAD_ATTEMPTS}" AND NOT _downloaded)
            file(DOWNLOAD "${url}" "${_temp_path}"
                SHOW_PROGRESS
                TIMEOUT 600
                INACTIVITY_TIMEOUT 60
                STATUS _download_status
            )
            list(LENGTH _download_status _download_status_length)
            if (_download_status_length GREATER 0)
                list(GET _download_status 0 _download_code)
            else()
                set(_download_code 1)
            endif()
            if (_download_status_length GREATER 1)
                list(GET _download_status 1 _download_text)
            else()
                set(_download_text "unknown error")
            endif()

            if (_download_code EQUAL 0)
                set(_downloaded TRUE)
            else()
                file(REMOVE "${_temp_path}")
                message(WARNING
                    "[${name}] download attempt ${_attempt}/${MUSE_DEPENDENCY_DOWNLOAD_ATTEMPTS} failed for ${url}: ${_download_text}")
                math(EXPR _attempt "${_attempt} + 1")
            endif()
        endwhile()

        if (NOT _downloaded)
            file(REMOVE "${_temp_path}")
            message(FATAL_ERROR
                "[${name}] could not download pinned payload ${url} after ${MUSE_DEPENDENCY_DOWNLOAD_ATTEMPTS} attempts "
                "(expected sha256 ${expected_sha256})")
        endif()
    endif()

    set(_verified FALSE)
    muse_dependency_verify_hash("${_temp_path}" "${expected_sha256}" _verified)
    if (NOT _verified)
        if (EXISTS "${_temp_path}")
            file(SHA256 "${_temp_path}" _actual_sha256)
        else()
            set(_actual_sha256 "none, no payload was written")
        endif()
        file(REMOVE "${_temp_path}")
        message(FATAL_ERROR
            "[${name}] payload ${url} has sha256 ${_actual_sha256}, which does not match the pinned "
            "sha256 ${expected_sha256}; refusing to use it. Review the payload and update "
            "dependencies.lock.cmake deliberately.")
    endif()

    # Atomic promotion: the destination only ever appears as a fully verified file.
    # file(RENAME) replaces an existing destination, so only stale unverified bytes (the
    # reason this function did not return early) are removed first.
    if (EXISTS "${archive_path}")
        file(REMOVE "${archive_path}")
    endif()
    file(RENAME "${_temp_path}" "${archive_path}")
    message(STATUS "[${name}] verified pinned payload ${archive_path}")
endfunction()

# Extract a single-root archive payload and move its content to <output_dir>/<destination>.
# <expected_paths> lists the reviewed, destination-prefixed layout of the whole dependency;
# the subset belonging to <destination> is validated inside the staging directory before the
# existing destination is replaced, so a bad payload cannot destroy a working payload.
function(muse_dependency_extract_payload name archive output_dir destination expected_paths)
    string(RANDOM LENGTH 8 ALPHABET "0123456789abcdef" _nonce)
    set(_staging_dir "${output_dir}/.staging-${name}-${_nonce}")
    file(MAKE_DIRECTORY "${_staging_dir}")

    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E tar xf "${archive}"
        WORKING_DIRECTORY "${_staging_dir}"
        RESULT_VARIABLE _extract_result
        OUTPUT_QUIET
        ERROR_VARIABLE _extract_error
    )
    if (NOT _extract_result EQUAL 0)
        file(REMOVE_RECURSE "${_staging_dir}")
        message(FATAL_ERROR
            "[${name}] ${archive} could not be extracted (it may be truncated or in an unsupported format): ${_extract_error}")
    endif()

    # Some libarchive implementations report damage on stderr while still returning 0 and
    # writing the entries they could read (for example a gzip stream whose tar body is
    # truncated). A payload that any extractor flags as damaged is never usable.
    if (NOT _extract_error STREQUAL "" AND _extract_error MATCHES "[Tt]runcated|[Dd]amaged|[Cc]orrupt|[Ii]nvalid")
        file(REMOVE_RECURSE "${_staging_dir}")
        message(FATAL_ERROR
            "[${name}] ${archive} could not be extracted (the archive reported: ${_extract_error})")
    endif()

    file(GLOB _roots RELATIVE "${_staging_dir}" "${_staging_dir}/*")
    list(LENGTH _roots _root_count)
    if (NOT _root_count EQUAL 1)
        file(REMOVE_RECURSE "${_staging_dir}")
        message(FATAL_ERROR
            "[${name}] unexpected archive root in ${archive}: expected exactly one top-level directory, "
            "found ${_root_count} (${_roots})")
    endif()

    list(GET _roots 0 _root)
    if (NOT IS_DIRECTORY "${_staging_dir}/${_root}")
        file(REMOVE_RECURSE "${_staging_dir}")
        message(FATAL_ERROR
            "[${name}] unexpected archive root in ${archive}: top-level entry '${_root}' is not a directory")
    endif()

    # Validate this payload's part of the reviewed layout inside staging: the destination is
    # only replaced by an archive that actually provides what the lock promises for it.
    string(LENGTH "${destination}/" _destination_prefix_length)
    foreach(_expected_path IN LISTS expected_paths)
        string(FIND "${_expected_path}" "${destination}/" _destination_prefix_index)
        if (NOT _destination_prefix_index EQUAL 0)
            continue()
        endif()
        string(SUBSTRING "${_expected_path}" ${_destination_prefix_length} -1 _expected_relative)
        if (NOT EXISTS "${_staging_dir}/${_root}/${_expected_relative}")
            file(REMOVE_RECURSE "${_staging_dir}")
            message(FATAL_ERROR
                "[${name}] ${archive} does not contain the reviewed path '${_expected_path}' for destination "
                "'${destination}'; the existing payload was left untouched")
        endif()
    endforeach()

    set(_destination_dir "${output_dir}/${destination}")
    file(MAKE_DIRECTORY "${output_dir}")
    file(REMOVE_RECURSE "${_destination_dir}")
    file(RENAME "${_staging_dir}/${_root}" "${_destination_dir}")
    file(REMOVE_RECURSE "${_staging_dir}")

    message(STATUS "[${name}] extracted pinned payload to ${_destination_dir}")
endfunction()

# Materialise every pinned payload of <name> under <output_dir>.
# The dependency is validated as a whole by its expected layout, but payloads are fetched,
# verified and extracted individually; a partially populated directory is never accepted.
function(muse_dependency_payload name output_dir)
    muse_dependency_lock_get(${name} PAYLOADS _payloads)
    muse_dependency_lock_get(${name} EXPECTED _expected)

    if (NOT _payloads)
        message(FATAL_ERROR
            "[${name}] is not pinned in buildscripts/cmake/deps/dependencies.lock.cmake; "
            "add its immutable payload URL and checked-in SHA-256 before enabling it")
    endif()
    if (NOT _expected)
        message(FATAL_ERROR
            "[${name}] has no EXPECTED layout in buildscripts/cmake/deps/dependencies.lock.cmake; "
            "the fetched payload could not be validated")
    endif()

    # One plan drives both the cache decision and the materialisation loop. It carries the
    # reviewed payload hashes, which a completed output directory is bound to: a lock change
    # can therefore never reuse a directory that was extracted from different bytes.
    set(_plan "")
    set(_pinned "")
    set(_identity_input "")
    foreach(_payload IN LISTS _payloads)
        string(REPLACE "|" ";" _fields "${_payload}")
        list(LENGTH _fields _field_count)
        if (NOT _field_count EQUAL 4)
            message(FATAL_ERROR
                "[${name}] malformed payload entry '${_payload}' in dependencies.lock.cmake; "
                "expected '<mode>|<destination>|<url>|<sha256>'")
        endif()

        list(GET _fields 0 _mode)
        list(GET _fields 1 _destination)
        list(GET _fields 2 _url)
        list(GET _fields 3 _sha256)

        if (NOT _mode STREQUAL "single-root")
            message(FATAL_ERROR
                "[${name}] unsupported payload mode '${_mode}' in dependencies.lock.cmake")
        endif()

        # The archive is cached under its expected hash, never under its URL basename, so the
        # same reviewed bytes stay reusable when only the mirror URL changes.
        string(TOLOWER "${_sha256}" _archive_key)
        set(_archive_path "${output_dir}/.pinned/${_archive_key}")
        string(APPEND _identity_input "${_mode}|${_destination}|${_archive_key}\n")
        list(APPEND _plan "${_mode}|${_destination}|${_url}|${_sha256}|${_archive_path}")
        list(APPEND _pinned "${_archive_key}|${_archive_path}")
    endforeach()
    string(SHA256 _identity "${_identity_input}")
    set(_stamp_path "${output_dir}/.pinned/payloads.identity")

    set(_missing "")
    foreach(_expected_path IN LISTS _expected)
        if (NOT EXISTS "${output_dir}/${_expected_path}")
            list(APPEND _missing "${_expected_path}")
        endif()
    endforeach()

    # Reuse a complete directory only when it records exactly these reviewed payload hashes
    # and the archives it was extracted from are still present and still those bytes.
    set(_reusable FALSE)
    if (NOT _missing AND EXISTS "${_stamp_path}")
        file(READ "${_stamp_path}" _recorded_identity)
        string(STRIP "${_recorded_identity}" _recorded_identity)
        if (_recorded_identity STREQUAL "${_identity}")
            set(_reusable TRUE)
            foreach(_pin IN LISTS _pinned)
                string(REPLACE "|" ";" _pin_fields "${_pin}")
                list(GET _pin_fields 0 _pin_sha256)
                list(GET _pin_fields 1 _pin_path)
                muse_dependency_verify_hash("${_pin_path}" "${_pin_sha256}" _pin_verified)
                if (NOT _pin_verified)
                    set(_reusable FALSE)
                endif()
            endforeach()
        endif()
    endif()
    if (_reusable)
        message(STATUS "[${name}] validated pinned payload in ${output_dir}")
        return()
    endif()

    file(MAKE_DIRECTORY "${output_dir}")
    message(STATUS "[${name}] resolving pinned payload into ${output_dir} (missing: ${_missing})")

    foreach(_entry IN LISTS _plan)
        string(REPLACE "|" ";" _fields "${_entry}")
        list(GET _fields 0 _mode)
        list(GET _fields 1 _destination)
        list(GET _fields 2 _url)
        list(GET _fields 3 _sha256)
        list(GET _fields 4 _archive_path)

        # An incomplete previous attempt leaves the dependency failing its layout check above,
        # so only this payload's own destination is discarded. The verified archive must
        # satisfy this destination's reviewed layout inside staging before that happens.
        file(REMOVE_RECURSE "${output_dir}/${_destination}")

        muse_dependency_fetch_payload(${name} "${_url}" "${_sha256}" "${_archive_path}")
        muse_dependency_extract_payload(${name} "${_archive_path}" "${output_dir}" "${_destination}" "${_expected}")
    endforeach()

    set(_missing "")
    foreach(_expected_path IN LISTS _expected)
        if (NOT EXISTS "${output_dir}/${_expected_path}")
            list(APPEND _missing "${_expected_path}")
        endif()
    endforeach()
    if (_missing)
        message(FATAL_ERROR
            "[${name}] pinned payload was fetched but its expected layout is incomplete: ${_missing}")
    endif()

    # Record the reviewed payload hashes that produced this directory.
    file(MAKE_DIRECTORY "${output_dir}/.pinned")
    file(WRITE "${_stamp_path}" "${_identity}\n")

    message(STATUS "[${name}] verified pinned payload in ${output_dir}")
endfunction()

# Include the reviewed recipe for <name> and call its <name>_Populate function.
#
# Recipe code is always taken from the source tree (MUSE_DEPS_RECIPE_DIR, or shadow it with
# a normal variable to point at another reviewed directory). Executable CMake is never
# downloaded from a moving branch, and a recipe that does not define the expected command is
# an error instead of a downstream "Unknown CMake command".
#
# Implemented as a macro so that the recipe function is defined in the calling scope.
macro(muse_dependency_populate name local_path)
    set(_muse_deps_recipe "${MUSE_DEPS_RECIPE_DIR}/${name}.cmake")

    if (NOT EXISTS "${_muse_deps_recipe}")
        file(GLOB _muse_deps_available RELATIVE "${MUSE_DEPS_RECIPE_DIR}" "${MUSE_DEPS_RECIPE_DIR}/*.cmake")
        message(FATAL_ERROR
            "[${name}] no reviewed recipe at ${_muse_deps_recipe}. Recipes are checked in under "
            "buildscripts/cmake/deps and executable CMake is never fetched from a remote branch. "
            "Available recipes: ${_muse_deps_available}")
    endif()

    include("${_muse_deps_recipe}")

    if (NOT COMMAND ${name}_Populate)
        message(FATAL_ERROR
            "[${name}] recipe ${_muse_deps_recipe} does not define the expected command ${name}_Populate")
    endif()

    cmake_language(CALL ${name}_Populate "${local_path}")

    unset(_muse_deps_recipe)
    unset(_muse_deps_available)
endmacro()
