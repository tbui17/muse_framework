# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2024 MuseScore Limited and others
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
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

if (MUSE_USE_SYSTEM_HARFBUZZ)
    find_package(HarfBuzz)

    if (HarfBuzz_FOUND)
        message(STATUS "Found HarfBuzz")

        # See HarfBuzz's harfbuzz-config.cmake, which is quite minimalistic
        set(HARFBUZZ_LIBRARIES harfbuzz::harfbuzz)
        set(HARFBUZZ_INCLUDE_DIRS ${HARFBUZZ_INCLUDE_DIR})

        return()
    else()
        message(WARNING "Set MUSE_USE_SYSTEM_HARFBUZZ=ON, but system harfbuzz not found, built-in will be used")
    endif()
endif()

# If not MUSE_USE_SYSTEM_HARFBUZZ, or if it was not found,
# use the pinned HarfBuzz source.
#
# The reviewed recipe is buildscripts/cmake/deps/harfbuzz.cmake; its payload URL and
# SHA-256 are pinned in buildscripts/cmake/deps/dependencies.lock.cmake. The source is
# extracted into the build tree, while the MuseScore build wrapper (which compiles the
# amalgamated harfbuzz.cc) is checked in at framework/draw/thirdparty/harfbuzz.
include(DependencyPayload)

muse_dependency_output_dir(harfbuzz harfbuzz_output_dir)
muse_dependency_populate(harfbuzz "${harfbuzz_output_dir}")

set(HARFBUZZ_SOURCE_DIR "${harfbuzz_output_dir}/harfbuzz")
set(HB_HAVE_FREETYPE ON)

# HarfBuzz is licensed under the "Old MIT" license; the Microsoft Uniscribe shaper it
# embeds under src/ms-use carries its own MIT text.
include(SetupLicenseNotices)
muse_install_license_notice(harfbuzz "${HARFBUZZ_SOURCE_DIR}" "COPYING" "src/ms-use/COPYING")

# Checked-in build wrapper, mirroring how SetupFreeType.cmake pulls in its thirdparty
# directory; it compiles the amalgamated source from HARFBUZZ_SOURCE_DIR.
add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/../thirdparty/harfbuzz harfbuzz)

target_no_warning(harfbuzz -Wno-conversion)
target_no_warning(harfbuzz -Wno-unused-parameter)
target_no_warning(harfbuzz -Wno-unused-variable)
target_no_warning(harfbuzz -WMSVC-no-hides-previous)
target_no_warning(harfbuzz -WMSVC-no-unreachable)

#add_subdirectory(thirdparty/msdfgen)

set(HARFBUZZ_LIBRARIES harfbuzz)
set(HARFBUZZ_INCLUDE_DIRS ${HARFBUZZ_SOURCE_DIR}/src)
