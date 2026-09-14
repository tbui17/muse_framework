# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# Reviewed recipe for FLAC 1.4.3. The source archive and SHA-256 are pinned in
# dependencies.lock.cmake and are materialised in the build tree only.

function(flac_Populate local_path)
    muse_dependency_payload(flac "${local_path}")

    if (NOT TARGET Ogg::ogg)
        message(FATAL_ERROR "[flac] the canonical Ogg::ogg dependency target is unavailable")
    endif()

    set(src_path "${local_path}/flac-1.4.3")
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared FLAC libraries" FORCE)
    set(BUILD_CXXLIBS ON CACHE BOOL "Build libFLAC++" FORCE)
    set(BUILD_PROGRAMS OFF CACHE BOOL "Build FLAC programs" FORCE)
    set(BUILD_EXAMPLES OFF CACHE BOOL "Build FLAC examples" FORCE)
    set(BUILD_DOCS OFF CACHE BOOL "Build FLAC documentation" FORCE)
    set(INSTALL_MANPAGES OFF CACHE BOOL "Install FLAC man pages" FORCE)
    set(INSTALL_PKGCONFIG_MODULES OFF CACHE BOOL "Install FLAC pkg-config metadata" FORCE)
    set(INSTALL_CMAKE_CONFIG_MODULE OFF CACHE BOOL "Install FLAC CMake package metadata" FORCE)
    set(WITH_OGG ON CACHE BOOL "Build FLAC Ogg support" FORCE)

    set(_muse_build_testing_was_defined FALSE)
    if (DEFINED BUILD_TESTING)
        set(_muse_build_testing_was_defined TRUE)
        set(_muse_build_testing_value "${BUILD_TESTING}")
    endif()
    get_property(_muse_build_testing_cache_defined CACHE BUILD_TESTING PROPERTY TYPE SET)
    if (_muse_build_testing_cache_defined)
        get_property(_muse_build_testing_cache_type CACHE BUILD_TESTING PROPERTY TYPE)
        get_property(_muse_build_testing_cache_help CACHE BUILD_TESTING PROPERTY HELPSTRING)
        get_property(_muse_build_testing_cache_value CACHE BUILD_TESTING PROPERTY VALUE)
    endif()
    set(BUILD_TESTING OFF)
    set(BUILD_TESTING OFF CACHE BOOL "Build FLAC tests" FORCE)

    set(_muse_legacy_policy_guard FALSE)
    if (CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
        set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
        set(_muse_legacy_policy_guard TRUE)
    endif()

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/muse-deps-flac" EXCLUDE_FROM_ALL)

    if (_muse_legacy_policy_guard)
        unset(CMAKE_POLICY_VERSION_MINIMUM)
    endif()

    if (_muse_build_testing_cache_defined)
        set(BUILD_TESTING "${_muse_build_testing_cache_value}" CACHE
            ${_muse_build_testing_cache_type} "${_muse_build_testing_cache_help}" FORCE)
    else()
        unset(BUILD_TESTING CACHE)
    endif()

    if (_muse_build_testing_was_defined)
        set(BUILD_TESTING "${_muse_build_testing_value}")
    else()
        unset(BUILD_TESTING)
    endif()

    if (NOT TARGET FLAC::FLAC OR NOT TARGET FLAC::FLAC++)
        message(FATAL_ERROR "[flac] upstream source did not provide FLAC::FLAC and FLAC::FLAC++")
    endif()
    set_property(GLOBAL PROPERTY flac_SOURCE_DIR "${src_path}")
endfunction()
