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
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# MuseScore build wrapper for HarfBuzz.
#
# The pinned HarfBuzz source tree is materialised by the reviewed recipe in
# buildscripts/cmake/deps/harfbuzz.cmake (payload pinned in deps/dependencies.lock.cmake)
# and is located by HARFBUZZ_SOURCE_DIR, which framework/draw/cmake/SetupHarfBuzz.cmake
# sets before adding this directory. Only the amalgamated source is compiled.

muse_create_thirdparty_module(harfbuzz)

if (NOT HARFBUZZ_SOURCE_DIR)
    message(FATAL_ERROR "[harfbuzz] HARFBUZZ_SOURCE_DIR must point at the pinned HarfBuzz source tree")
endif()

target_sources(harfbuzz PRIVATE
    ${HARFBUZZ_SOURCE_DIR}/src/harfbuzz.cc
)

target_include_directories(harfbuzz PRIVATE
    ${FREETYPE_INCLUDE_DIRS}
)

target_compile_definitions(harfbuzz PRIVATE HAVE_FREETYPE)

target_no_warning(harfbuzz -Wno-truncate)
target_no_warning(harfbuzz -Wno-uninitialized)
