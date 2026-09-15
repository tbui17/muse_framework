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
# Reviewed recipe for LAME 3.100. The source archive and SHA-256 are pinned in
# dependencies.lock.cmake and are materialised in the build tree only. LAME has
# no supported upstream CMake build, so this checked-in wrapper provides the
# reviewed cross-platform static target expected by the framework.

function(lame_Populate local_path)
    muse_dependency_payload(lame "${local_path}")

    set(src_path "${local_path}/lame-3.100")
    file(WRITE "${src_path}/config.h"
        "#define STDC_HEADERS 1\n"
        "#define HAVE_ERRNO_H 1\n"
        "#define HAVE_FCNTL_H 1\n"
        "#define HAVE_LIMITS_H 1\n"
        "#define HAVE_STDINT_H 1\n"
        "#define HAVE_INTTYPES_H 1\n"
        "#define HAVE_STRCHR 1\n"
        "#define HAVE_MEMCPY 1\n"
        "#define HAVE_MPGLIB 1\n"
        "#define DECODE_ON_THE_FLY 1\n"
        "#define USE_FAST_LOG 1\n"
        "typedef float ieee754_float32_t;\n"
        "typedef double ieee754_float64_t;\n")
    file(WRITE "${src_path}/CMakeLists.txt"
        "cmake_minimum_required(VERSION 3.24)\n"
        "project(muse_lame C)\n"
        "add_definitions(-DHAVE_CONFIG_H)\n"
        "file(GLOB LAME_SOURCES libmp3lame/*.c mpglib/*.c)\n"
        "add_library(mp3lame STATIC \${LAME_SOURCES})\n"
        "add_library(libmp3lame::libmp3lame ALIAS mp3lame)\n"
        "set_target_properties(mp3lame PROPERTIES POSITION_INDEPENDENT_CODE ON)\n"
        "target_include_directories(mp3lame PUBLIC \${CMAKE_CURRENT_SOURCE_DIR}/include\n"
        "    PRIVATE \${CMAKE_CURRENT_SOURCE_DIR} \${CMAKE_CURRENT_SOURCE_DIR}/libmp3lame\n"
        "    \${CMAKE_CURRENT_SOURCE_DIR}/mpglib)\n")

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/muse-deps-lame" EXCLUDE_FROM_ALL)

    if (NOT TARGET libmp3lame::libmp3lame)
        message(FATAL_ERROR "[lame] reviewed wrapper did not provide libmp3lame::libmp3lame")
    endif()
    set_property(GLOBAL PROPERTY lame_SOURCE_DIR "${src_path}")
endfunction()
