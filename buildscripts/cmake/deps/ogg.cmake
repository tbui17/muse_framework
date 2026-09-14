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

    set(_muse_legacy_policy_guard FALSE)
    if (CMAKE_VERSION VERSION_GREATER_EQUAL 4.0)
        set(CMAKE_POLICY_VERSION_MINIMUM 3.5)
        set(_muse_legacy_policy_guard TRUE)
    endif()

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/muse-deps-ogg" EXCLUDE_FROM_ALL)

    if (_muse_legacy_policy_guard)
        unset(CMAKE_POLICY_VERSION_MINIMUM)
    endif()

    if (NOT TARGET Ogg::ogg)
        message(FATAL_ERROR "[ogg] upstream source did not provide the canonical Ogg::ogg target")
    endif()
    set_property(GLOBAL PROPERTY ogg_SOURCE_DIR "${src_path}")
endfunction()
