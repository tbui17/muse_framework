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
# Reviewed recipe for libogg 1.3.5. The source archive and SHA-256 are pinned in
# dependencies.lock.cmake and are materialised in the build tree only.

function(ogg_Populate local_path)
    muse_dependency_payload(ogg "${local_path}")

    set(src_path "${local_path}/libogg-1.3.5")
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libogg" FORCE)
    set(INSTALL_DOCS OFF CACHE BOOL "Install libogg documentation" FORCE)
    set(INSTALL_PKG_CONFIG_MODULE OFF CACHE BOOL "Install libogg pkg-config metadata" FORCE)
    set(INSTALL_CMAKE_PACKAGE_MODULE OFF CACHE BOOL "Install libogg CMake package metadata" FORCE)

    # Keep the third-party test executables out of the project test graph. The
    # source is added EXCLUDE_FROM_ALL, so registering them would create tests
    # that cannot be built by the project install target.
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
    set(BUILD_TESTING OFF CACHE BOOL "Build Ogg tests" FORCE)

    set(_muse_legacy_policy_guard FALSE)
    if (CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
        set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
        set(_muse_legacy_policy_guard TRUE)
    endif()

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/muse-deps-ogg" EXCLUDE_FROM_ALL)

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

    if (NOT TARGET Ogg::ogg)
        message(FATAL_ERROR "[ogg] upstream source did not provide the canonical Ogg::ogg target")
    endif()
    set_property(GLOBAL PROPERTY ogg_SOURCE_DIR "${src_path}")
endfunction()
