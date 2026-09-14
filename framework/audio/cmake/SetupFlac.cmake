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

if (MUSE_USE_SYSTEM_FLAC)
    find_package(FLAC QUIET)

    if (FLAC_FOUND AND TARGET FLAC::FLAC AND TARGET FLAC::FLAC++)
        message(STATUS "Found flac: ${FLAC_VERSION}")
        set(FLAC_TARGETS FLAC::FLAC FLAC::FLAC++)
        return()
    endif()

    find_package(PkgConfig QUIET)
    if (PkgConfig_FOUND)
        pkg_check_modules(flac QUIET IMPORTED_TARGET flac)
        pkg_check_modules(flacpp QUIET IMPORTED_TARGET flac++)
        if (TARGET PkgConfig::flac AND TARGET PkgConfig::flacpp)
            if (NOT TARGET FLAC::FLAC)
                add_library(FLAC::FLAC ALIAS PkgConfig::flac)
            endif()
            if (NOT TARGET FLAC::FLAC++)
                add_library(FLAC::FLAC++ ALIAS PkgConfig::flacpp)
            endif()
            message(STATUS "Found flac through pkg-config")
            set(FLAC_TARGETS FLAC::FLAC FLAC::FLAC++)
            return()
        endif()
    endif()

    message(WARNING "Set MUSE_USE_SYSTEM_FLAC=ON, but system flac was not usable; the pinned source will be used")
endif()

if (NOT TARGET Ogg::ogg)
    populate(ogg)
endif()
if (NOT TARGET FLAC::FLAC OR NOT TARGET FLAC::FLAC++)
    populate(flac)
endif()

if (NOT TARGET FLAC::FLAC OR NOT TARGET FLAC::FLAC++)
    message(FATAL_ERROR "[flac] the canonical FLAC::FLAC and FLAC::FLAC++ targets are unavailable")
endif()
set(FLAC_TARGETS FLAC::FLAC FLAC::FLAC++)
