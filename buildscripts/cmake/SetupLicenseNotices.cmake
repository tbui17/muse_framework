# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# License and notice installation for the files that are shipped to users.
#
# Every notice is copied verbatim from the tree that actually produced the shipped
# binary: the pinned dependency payload for fetched dependencies, the vendored source
# directory for in-tree third party, or a pinned notice payload for components whose
# own archive carries no notice (see buildscripts/cmake/deps/license_notices.cmake).
# A missing notice file is a configure error, so an install tree can never be built
# with a silently incomplete notice set.
#
# The destination is <resources>/licenses/<name>, next to the other resource
# directories (sound, styles, templates, locale).

include_guard()

# CMake 3.31 warns when install() receives a destination such as ./licenses.
# Normalize only the destination used by these notice rules, without changing the
# global policy or the install root selected by the application.
function(muse_license_normalize_destination output_variable relative_destination)
    set(destination "${MUSE_APP_INSTALL_RESOURCES_LOCATION}/${relative_destination}")
    cmake_path(NORMAL_PATH destination)
    set(${output_variable} "${destination}" PARENT_SCOPE)
endfunction()

# muse_install_license_notice(<name> <source-dir> <relative-file>...)
#
# The optional <subdir> argument is spelled as part of the relative path, so a
# dependency that keeps several notice files apart (for example common/LICENSE.txt
# and LICENSE.txt) keeps that structure in the install tree.
function(muse_install_license_notice name source_dir)
    if (NOT MUSE_APP_INSTALL_RESOURCES_LOCATION)
        message(FATAL_ERROR
            "[licenses] MUSE_APP_INSTALL_RESOURCES_LOCATION is not set; cannot install the "
            "${name} notices.")
    endif()

    muse_license_normalize_destination(destination "licenses/${name}")
    set(missing "")
    foreach (relative IN LISTS ARGN)
        if (NOT EXISTS "${source_dir}/${relative}")
            list(APPEND missing "${relative}")
        endif()
    endforeach()

    if (missing)
        message(FATAL_ERROR
            "[licenses] ${name}: notice file(s) ${missing} were not found under '${source_dir}'. "
            "The pinned payload or the vendored source changed; update the notice set instead of "
            "shipping an incomplete license directory.")
    endif()

    foreach (relative IN LISTS ARGN)
        get_filename_component(file_name "${relative}" NAME)
        get_filename_component(file_dir "${relative}" DIRECTORY)
        if (file_dir)
            install(FILES "${source_dir}/${relative}"
                DESTINATION "${destination}/${file_dir}")
        else()
            install(FILES "${source_dir}/${relative}"
                DESTINATION "${destination}")
        endif()
        message(STATUS "[licenses] ${name}: ${file_name}")
    endforeach()
endfunction()

# muse_install_qt_module_notices(<notice-payload-root> <module>...)
#
# The Qt license texts alone are not attribution. Each shipped Qt module's own source
# archive carries its LICENSES set, its REUSE.toml/licenseRule.json and qt_attribution.json
# files. Every legal file named by that metadata is installed verbatim. We do not scan
# arbitrary source files by name: the set is the canonical Qt license metadata plus the
# files explicitly referenced by each attribution record.
function(muse_install_qt_module_notices notice_payload_root)
    if (NOT MUSE_APP_INSTALL_RESOURCES_LOCATION)
        message(FATAL_ERROR
            "[licenses] MUSE_APP_INSTALL_RESOURCES_LOCATION is not set; cannot install the "
            "Qt module notices.")
    endif()

    set(requested_modules ${ARGN})

    set(required
        "qtbase|src/dbus/LICENSE.LIBDBUS-1.txt"
        "qtbase|src/3rdparty/freetype/LICENSE.txt"
        "qtbase|src/3rdparty/harfbuzz-ng/COPYING"
        "qtbase|src/3rdparty/libpng/LICENSE"
        "qtbase|src/3rdparty/zlib/LICENSE"
        "qtbase|LICENSES/LGPL-3.0-only.txt"
        "qtbase|LICENSES/Qt-GPL-exception-1.0.txt"
        "qtdeclarative|src/3rdparty/yoga/LICENSE"
        "qtsvg|src/svg/LICENSE.XSVG.txt"
        "qttools|src/assistant/qlitehtml/src/3rdparty/litehtml/LICENSE"
        "qttools|src/qdoc/catch/LICENSE.CATCH.txt"
        "qt5compat|src/core5/codecs/LICENSE.QBIG5CODEC.txt"
        "qtshadertools|src/3rdparty/glslang/LICENSE.txt"
        "qtshadertools|src/3rdparty/SPIRV-Cross/LICENSE"
        "qtnetworkauth|LICENSES/BSD-3-Clause.txt"
        "qttranslations|LICENSES/GPL-3.0-only.txt"
        "qtwebsockets|LICENSES/LGPL-3.0-only.txt"
    )
    foreach (entry IN LISTS required)
        string(REPLACE "|" ";" parts "${entry}")
        list(GET parts 0 module)
        list(GET parts 1 relative)
        list(FIND requested_modules "${module}" module_index)
        if (module_index EQUAL -1)
            continue()
        endif()
        set(root "${notice_payload_root}/${module}-everywhere-src-6.10.2")
        if (NOT EXISTS "${root}/${relative}")
            message(FATAL_ERROR
                "[licenses] Qt ${module}: the required notice '${relative}' is missing from the "
                "pinned source archive at '${root}'. Update the notice set instead of shipping "
                "Qt without its third-party attribution.")
        endif()
    endforeach()

    foreach (module IN LISTS ARGN)
        set(root "${notice_payload_root}/${module}-everywhere-src-6.10.2")
        if (NOT IS_DIRECTORY "${root}")
            message(FATAL_ERROR "[licenses] Qt ${module}: source archive not found at '${root}'.")
        endif()
        file(REAL_PATH "${root}" root_real)

        # Canonical Qt license texts and metadata are legal material even when no
        # qt_attribution.json points to an individual text.
        file(GLOB_RECURSE all_module_files LIST_DIRECTORIES false "${root}/*")
        set(canonical_license_files "")
        foreach (module_file IN LISTS all_module_files)
            file(RELATIVE_PATH module_relative "${root}" "${module_file}")
            if (module_relative MATCHES "(^|/)LICENSES/[^/]+\\.txt$")
                list(APPEND canonical_license_files "${module_file}")
            endif()
        endforeach()
        file(GLOB_RECURSE reuse_files LIST_DIRECTORIES false
            "${root}/REUSE.toml")
        file(GLOB_RECURSE license_rule_files LIST_DIRECTORIES false
            "${root}/licenseRule.json")
        set(notices ${canonical_license_files} ${reuse_files} ${license_rule_files})

        file(GLOB_RECURSE attribution_files LIST_DIRECTORIES false
            "${root}/qt_attribution.json")
        # Some Qt modules (for example qttranslations and qtnetworkauth) have no
        # third-party attribution records. Their canonical LICENSES/REUSE metadata is
        # still installed and must keep the module covered.
        foreach (attribution IN LISTS attribution_files)
            list(APPEND notices "${attribution}")
            file(READ "${attribution}" attribution_json)

            # Qt's qtattributionsscanner resolves LicenseFile(s) and CopyrightFile relative to
            # the directory containing qt_attribution.json. Its Path field describes the package
            # source files and does not change the legal-file base directory. Match that behavior
            # exactly and fail closed when the referenced file is absent.
            string(REGEX MATCHALL
                "\"(LicenseFiles?|CopyrightFile)\"[ \t\r\n]*:[ \t\r\n]*(\\[[^]]*\\]|\"[^\"]*\")"
                reference_fields "${attribution_json}")
            foreach (reference_field IN LISTS reference_fields)
                string(REGEX REPLACE "^[^:]+:[ \t\r\n]*" "" reference_payload "${reference_field}")
                string(REGEX MATCHALL "\"[^\"]*\"" reference_values "${reference_payload}")
                foreach (reference_value IN LISTS reference_values)
                    string(REGEX REPLACE "^\"(.*)\"$" "\\1" reference "${reference_value}")
                    if (NOT reference STREQUAL "")
                        get_filename_component(attribution_dir "${attribution}" DIRECTORY)
                        get_filename_component(candidate "${attribution_dir}/${reference}" ABSOLUTE)
                        if (EXISTS "${candidate}")
                            file(REAL_PATH "${candidate}" candidate_real)
                        else()
                            set(candidate_real "${candidate}")
                        endif()
                        file(RELATIVE_PATH candidate_relative "${root_real}" "${candidate_real}")
                        if (candidate_relative MATCHES "^\\.\\.(/|$)")
                            message(FATAL_ERROR
                                "[licenses] Qt ${module}: attribution '${attribution}' references "
                                "legal file '${reference}' outside its module source root.")
                        elseif (NOT EXISTS "${candidate}" OR IS_DIRECTORY "${candidate}")
                            message(FATAL_ERROR
                                "[licenses] Qt ${module}: attribution '${attribution}' references "
                                "missing legal file '${reference}' relative to its metadata directory.")
                        endif()
                        list(APPEND notices "${candidate}")
                    endif()
                endforeach()
            endforeach()
        endforeach()

        list(REMOVE_DUPLICATES notices)
        list(SORT notices)
        list(LENGTH notices notice_count)
        if (notice_count EQUAL 0)
            message(FATAL_ERROR
                "[licenses] Qt ${module}: no canonical license metadata or attribution file "
                "was found under '${root}'.")
        endif()
        foreach (notice IN LISTS notices)
            file(RELATIVE_PATH relative "${root}" "${notice}")
            get_filename_component(directory "${relative}" DIRECTORY)
            if (directory)
                muse_license_normalize_destination(destination
                    "licenses/qt-libraries/${module}/${directory}")
                install(FILES "${notice}" DESTINATION "${destination}")
            else()
                muse_license_normalize_destination(destination
                    "licenses/qt-libraries/${module}")
                install(FILES "${notice}" DESTINATION "${destination}")
            endif()
        endforeach()
        message(STATUS "[licenses] qt-libraries/${module}: ${notice_count} metadata/legal file(s)")
    endforeach()
endfunction()

# muse_install_source_index(<path>|<note>...)
#
# Writes licenses/SOURCE-REFS.txt so the artifact carries the exact sources of
# the components whose notices it ships: every pinned payload archive with its SHA-256,
# plus the vendored directories compiled into the binary and the source revisions when
# the checkout is a Git worktree.
function(muse_install_source_index)
    if (NOT MUSE_APP_INSTALL_RESOURCES_LOCATION)
        message(FATAL_ERROR
            "[licenses] MUSE_APP_INSTALL_RESOURCES_LOCATION is not set; cannot install the "
            "source reference index.")
    endif()

    set(content "MuseScore Studio fork release: license and notice source index\n")
    string(APPEND content "Generated at configure time from buildscripts/cmake/deps/dependencies.lock.cmake.\n")
    string(APPEND content "\nPinned payload archives (dependency, directory, URL, SHA-256):\n")

    get_cmake_property(_variables VARIABLES)
    list(SORT _variables)
    foreach (_variable IN LISTS _variables)
        if (_variable MATCHES "^MUSE_DEP_(.+)_PAYLOADS$")
            set(_dependency "${CMAKE_MATCH_1}")
            foreach (_entry IN LISTS ${_variable})
                if (_entry MATCHES "^single-root\\|([^|]+)\\|([^|]+)\\|([0-9a-f]+)$")
                    string(APPEND content "  ${_dependency}  ${CMAKE_MATCH_1}  ${CMAKE_MATCH_2}  ${CMAKE_MATCH_3}\n")
                endif()
            endforeach()
        endif()
    endforeach()

    string(APPEND content "\nApplication and framework source revisions used for this install:\n")
    execute_process(
        COMMAND git -C "${PROJECT_SOURCE_DIR}" rev-parse HEAD
        OUTPUT_VARIABLE _application_sha
        RESULT_VARIABLE _application_result
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_QUIET)
    if (_application_result EQUAL 0 AND _application_sha MATCHES "^[0-9a-f]+$")
        string(APPEND content "  application  ${_application_sha}\n")
    endif()

    if (DEFINED MUSE_FRAMEWORK_PATH AND IS_DIRECTORY "${MUSE_FRAMEWORK_PATH}")
        execute_process(
            COMMAND git -C "${MUSE_FRAMEWORK_PATH}" rev-parse HEAD
            OUTPUT_VARIABLE _framework_sha
            RESULT_VARIABLE _framework_result
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET)
        if (_framework_result EQUAL 0 AND _framework_sha MATCHES "^[0-9a-f]+$")
            string(APPEND content "  framework  ${_framework_sha}\n")
        endif()
    endif()

    string(APPEND content "\nVendored third party compiled into the shipped binary (source path | note):\n")
    foreach (_pair IN LISTS ARGN)
        string(REPLACE "|" "  " _line "${_pair}")
        string(APPEND content "  ${_line}\n")
    endforeach()

    string(APPEND content "\nQt 6.10.2: license texts, attribution metadata, and referenced legal files come from\n")
    string(APPEND content "the pinned source archive for each shipped Qt module. The Qt binary packages\n")
    string(APPEND content "carry no license texts.\n")

    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/SOURCE-REFS.txt" "${content}")
    muse_license_normalize_destination(destination "licenses")
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/SOURCE-REFS.txt"
        DESTINATION "${destination}")
    message(STATUS "[licenses] source index: ${CMAKE_CURRENT_BINARY_DIR}/SOURCE-REFS.txt")
endfunction()

# muse_install_license_tree(<name> <source-dir> <relative-dir> <glob>)
#
# Installs every file matching <glob> under <relative-dir> (used for the Qt license
# text set, which is a directory of REUSE-style texts rather than a single file).
function(muse_install_license_tree name source_dir relative_dir pattern)
    set(from "${source_dir}/${relative_dir}")
    if (NOT IS_DIRECTORY "${from}")
        message(FATAL_ERROR
            "[licenses] ${name}: notice directory '${from}' is missing. "
            "The pinned payload changed; update the notice set instead of shipping an "
            "incomplete license directory.")
    endif()

    file(GLOB notice_files "${from}/${pattern}")
    list(LENGTH notice_files notice_count)
    if (notice_count EQUAL 0)
        message(FATAL_ERROR
            "[licenses] ${name}: no notice matched '${pattern}' under '${from}'.")
    endif()

    muse_license_normalize_destination(destination "licenses/${name}")
    install(FILES ${notice_files} DESTINATION "${destination}")
    message(STATUS "[licenses] ${name}: ${notice_count} notice file(s)")
endfunction()
