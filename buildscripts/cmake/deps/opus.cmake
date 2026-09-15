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
# Reviewed recipe for Opus 1.5.2. The source archive and SHA-256 are pinned in
# dependencies.lock.cmake and are materialised in the build tree only.

function(opus_Populate local_path)
    muse_dependency_payload(opus "${local_path}")

    set(src_path "${local_path}/opus-1.5.2")
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared Opus library" FORCE)
    set(OPUS_BUILD_SHARED_LIBRARY OFF CACHE BOOL "Build shared Opus library" FORCE)
    set(OPUS_BUILD_PROGRAMS OFF CACHE BOOL "Build Opus programs" FORCE)
    set(OPUS_BUILD_TESTING OFF CACHE BOOL "Build Opus tests" FORCE)
    set(OPUS_INSTALL_PKG_CONFIG_MODULE OFF CACHE BOOL "Install Opus pkg-config metadata" FORCE)
    set(OPUS_INSTALL_CMAKE_CONFIG_MODULE OFF CACHE BOOL "Install Opus CMake package metadata" FORCE)

    # Upstream enables its tests when the project-wide BUILD_TESTING is on, even if
    # OPUS_BUILD_TESTING is off. Isolate that option so third-party tests are not
    # registered without their executables in the project test graph.
    set(_muse_build_testing_was_defined FALSE)
    if (DEFINED BUILD_TESTING)
        set(_muse_build_testing_was_defined TRUE)
        set(_muse_build_testing_value "${BUILD_TESTING}")
    endif()
    set(BUILD_TESTING OFF)

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/muse-deps-opus" EXCLUDE_FROM_ALL)

    if (_muse_build_testing_was_defined)
        set(BUILD_TESTING "${_muse_build_testing_value}")
    else()
        unset(BUILD_TESTING)
    endif()

    if (NOT TARGET Opus::opus)
        message(FATAL_ERROR "[opus] upstream source did not provide the canonical Opus::opus target")
    endif()
    set_property(GLOBAL PROPERTY opus_SOURCE_DIR "${src_path}")
endfunction()
