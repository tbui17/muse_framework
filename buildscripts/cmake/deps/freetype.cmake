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
# Reviewed recipe for FreeType 2.14.1. The source archive and SHA-256 are pinned
# in dependencies.lock.cmake and materialised in the build tree only. The
# optional compression libraries are deliberately disabled here, matching the
# static MuseDeps build contract and keeping the source closure explicit.

function(freetype_Populate local_path)
    muse_dependency_payload(freetype "${local_path}")

    set(src_path "${local_path}/freetype-2.14.1")
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared FreeType library" FORCE)
    set(FT_DISABLE_ZLIB TRUE CACHE BOOL "Disable FreeType zlib support" FORCE)
    set(FT_DISABLE_BZIP2 TRUE CACHE BOOL "Disable FreeType bzip2 support" FORCE)
    set(FT_DISABLE_PNG TRUE CACHE BOOL "Disable FreeType PNG support" FORCE)
    set(FT_DISABLE_HARFBUZZ TRUE CACHE BOOL "Disable FreeType HarfBuzz support" FORCE)
    set(FT_DISABLE_BROTLI TRUE CACHE BOOL "Disable FreeType Brotli support" FORCE)
    set(SKIP_INSTALL_HEADERS OFF CACHE BOOL "Install FreeType headers" FORCE)
    set(SKIP_INSTALL_LIBRARIES OFF CACHE BOOL "Install FreeType libraries" FORCE)
    set(SKIP_INSTALL_EXECUTABLES ON CACHE BOOL "Install FreeType executables" FORCE)
    set(SKIP_INSTALL_CMAKE_FILES ON CACHE BOOL "Install FreeType CMake files" FORCE)

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/muse-deps-freetype" EXCLUDE_FROM_ALL)

    if (TARGET freetype AND NOT TARGET freetype::freetype)
        add_library(freetype::freetype ALIAS freetype)
    endif()
    if (NOT TARGET freetype::freetype)
        message(FATAL_ERROR "[freetype] reviewed source did not provide freetype::freetype")
    endif()
    set_property(GLOBAL PROPERTY freetype_SOURCE_DIR "${src_path}")
endfunction()
