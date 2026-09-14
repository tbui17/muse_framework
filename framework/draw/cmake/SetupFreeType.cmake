# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2023 MuseScore Limited and others
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

if (MUSE_USE_SYSTEM_FREETYPE)
    find_package(Freetype)

    if (FREETYPE_FOUND AND TARGET Freetype::Freetype)
        message(STATUS "Found freetype: ${FREETYPE_VERSION_STRING}")
        if (NOT TARGET freetype::freetype)
            add_library(freetype::freetype ALIAS Freetype::Freetype)
        endif()
        set(FREETYPE_LIBRARIES freetype::freetype)
        return()
    else()
        message(WARNING "Set MUSE_USE_SYSTEM_FREETYPE=ON, but system freetype was not usable; built-in will be used")
    endif()
endif()

# The reviewed recipe pins the source archive and exposes the same lowercase target expected by
# current-main MuseDeps consumers. Its payload is materialised under the build tree.
include(MuseDeps)
populate(freetype)
get_property(_freetype_source_dir GLOBAL PROPERTY freetype_SOURCE_DIR)
if (NOT _freetype_source_dir OR NOT TARGET freetype::freetype)
    message(FATAL_ERROR "[freetype] the canonical freetype::freetype target or source directory is unavailable")
endif()
set(FREETYPE_LIBRARIES freetype::freetype)
set(FREETYPE_INCLUDE_DIRS "${_freetype_source_dir}/include")

if (MUSE_APP_INSTALL_RESOURCES_LOCATION)
    # FreeType is offered under the FreeType License or GPL-2.0; ship all legal texts from the
    # exact payload that produced freetype::freetype.
    include(SetupLicenseNotices)
    muse_install_license_notice(freetype
        "${_freetype_source_dir}"
        "LICENSE.TXT" "docs/FTL.TXT" "docs/GPLv2.TXT")
endif()
