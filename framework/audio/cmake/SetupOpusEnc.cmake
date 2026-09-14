# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
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
set(MUSE_OPUSENC_SYSTEM OFF)

if (MUSE_USE_SYSTEM_OPUSENC)
    if (PkgConfig_FOUND)
        pkg_check_modules(libopusenc QUIET IMPORTED_TARGET libopusenc)
        pkg_check_modules(opus QUIET IMPORTED_TARGET opus)

        if (TARGET PkgConfig::libopusenc AND TARGET PkgConfig::opus)
            if (NOT TARGET Opus::opus)
                add_library(Opus::opus ALIAS PkgConfig::opus)
            endif()
            message(STATUS "Found opusenc through pkg-config")
            set(LIBOPUSENC_TARGETS PkgConfig::libopusenc PkgConfig::opus)
            set(MUSE_OPUSENC_SYSTEM ON)
            return()
        endif()
    endif()

    message(WARNING "Set MUSE_USE_SYSTEM_OPUSENC=ON, but system opusenc was not usable; the pinned source will be used")
endif()

if (NOT TARGET Ogg::ogg)
    populate(ogg)
endif()
if (NOT TARGET Opus::opus)
    populate(opus)
endif()
if (NOT TARGET opusenc::opusenc)
    populate(opusenc)
endif()

if (NOT TARGET opusenc::opusenc)
    message(FATAL_ERROR "[opusenc] the canonical opusenc::opusenc target is unavailable")
endif()
set(LIBOPUSENC_TARGETS opusenc::opusenc)
