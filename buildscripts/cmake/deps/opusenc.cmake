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
# Reviewed recipe for libopusenc 0.2.1. The source archive and SHA-256 are
# pinned in dependencies.lock.cmake and materialised in the build tree only.
# libopusenc has no supported upstream CMake build, so this wrapper is the
# reviewed static build and links the canonical Ogg and Opus targets.

function(opusenc_Populate local_path)
    muse_dependency_payload(opusenc "${local_path}")

    if (NOT TARGET Ogg::ogg)
        message(FATAL_ERROR "[opusenc] the canonical Ogg::ogg dependency target is unavailable")
    endif()
    if (NOT TARGET Opus::opus)
        message(FATAL_ERROR "[opusenc] the canonical Opus::opus dependency target is unavailable")
    endif()

    set(src_path "${local_path}/libopusenc-0.2.1")
    file(WRITE "${src_path}/config.h"
        "#define PACKAGE_NAME \"libopusenc\"\n"
        "#define PACKAGE_VERSION \"0.2.1\"\n")
    file(WRITE "${src_path}/CMakeLists.txt"
        "cmake_minimum_required(VERSION 3.24)\n"
        "project(muse_opusenc C)\n"
        "add_library(opusenc STATIC src/ogg_packer.c src/opus_header.c src/opusenc.c src/picture.c\n"
        "    src/resample.c src/unicode_support.c)\n"
        "add_library(opusenc::opusenc ALIAS opusenc)\n"
        "set_target_properties(opusenc PROPERTIES POSITION_INDEPENDENT_CODE ON)\n"
        "target_compile_definitions(opusenc PRIVATE HAVE_CONFIG_H OUTSIDE_SPEEX RANDOM_PREFIX=opusenc_prefix)\n"
        "target_include_directories(opusenc PUBLIC \${CMAKE_CURRENT_SOURCE_DIR}/include\n"
        "    PRIVATE \${CMAKE_CURRENT_SOURCE_DIR} \${CMAKE_CURRENT_SOURCE_DIR}/src)\n"
        "target_link_libraries(opusenc PUBLIC Ogg::ogg Opus::opus)\n")

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/muse-deps-opusenc" EXCLUDE_FROM_ALL)

    if (NOT TARGET opusenc::opusenc)
        message(FATAL_ERROR "[opusenc] reviewed wrapper did not provide opusenc::opusenc")
    endif()
    set_property(GLOBAL PROPERTY opusenc_SOURCE_DIR "${src_path}")
endfunction()
