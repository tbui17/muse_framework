# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Reviewed recipe for fdk-aac. The payload (upstream 2.0.3 tag archive) is pinned with
# its SHA-256 in dependencies.lock.cmake and is fetched into the build tree, never into
# this directory.

function(fdk-aac_Populate local_path)
    muse_dependency_payload(fdk-aac "${local_path}")

    set(src_path "${local_path}/fdk-aac-2.0.3")

    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared library" FORCE)
    set(BUILD_PROGRAMS OFF CACHE BOOL "Build extra utilities" FORCE)

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/fdk-aac" EXCLUDE_FROM_ALL)

    set_property(GLOBAL PROPERTY fdk-aac_SOURCE_DIR "${src_path}")
endfunction()
