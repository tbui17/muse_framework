# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Windows prebuilt native dependencies (zlib, libsndfile).
#
# The payload is the immutable codeload archive of a pinned revision; its URL and SHA-256
# are recorded in buildscripts/cmake/deps/dependencies.lock.cmake and its expected layout
# is validated by the reviewed recipe (buildscripts/cmake/deps/musescore_prebuild_win_deps.cmake).
# It is fetched into the build tree, never into the source tree, and a cold configure never
# follows the moving HEAD of a remote branch.
#
# Layout provided by the pinned revision:
#   <root>/include/zlib/zlib.h, <root>/include/sndfile.h
#   <root>/libx64/zlibstat.lib, <root>/libx64/libsndfile-1.lib

include(DependencyPayload)

if (OS_IS_WIN)
    muse_dependency_output_dir(musescore_prebuild_win_deps _prebuilt_win_deps_output_dir)
    muse_dependency_populate(musescore_prebuild_win_deps "${_prebuilt_win_deps_output_dir}")

    get_property(DEPENDENCIES_DIR GLOBAL PROPERTY musescore_prebuild_win_deps_SOURCE_DIR)

    set(DEPENDENCIES_LIB_DIR ${DEPENDENCIES_DIR}/libx64)
    set(DEPENDENCIES_INC ${DEPENDENCIES_DIR}/include)

    message(STATUS "Windows prebuilt dependencies: ${DEPENDENCIES_DIR}")
endif(OS_IS_WIN)
