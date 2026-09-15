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
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Reviewed recipe for GoogleTest 1.17.0. The source archive and SHA-256 are
# pinned in dependencies.lock.cmake and materialised in the build tree only.
# The test dependency is populated only when MUSE_ENABLE_UNIT_TESTS is enabled.

function(googletest_Populate local_path)
    muse_dependency_payload(googletest "${local_path}")

    if (NOT EXISTS "${local_path}/googletest/CMakeLists.txt")
        message(FATAL_ERROR "[googletest] pinned source tree is missing its googletest CMake project")
    endif()
    set_property(GLOBAL PROPERTY googletest_SOURCE_DIR "${local_path}")
endfunction()

# Preserve the current-main MuseDeps meta.cmake contract used by framework/CMakeLists.txt.
function(googletest_add_to_build)
    if (TARGET gtest)
        return()
    endif()

    get_property(_src GLOBAL PROPERTY googletest_SOURCE_DIR)
    if (NOT _src OR NOT EXISTS "${_src}/googletest/CMakeLists.txt")
        message(FATAL_ERROR "[googletest] source directory is unavailable; populate(googletest) must run first")
    endif()

    set(GOOGLETEST_VERSION 1.17.0)
    set(INSTALL_GTEST OFF)
    add_subdirectory("${_src}/googletest" googletest)

    if (NOT TARGET gtest)
        message(FATAL_ERROR "[googletest] upstream source did not provide the canonical gtest target")
    endif()
endfunction()
