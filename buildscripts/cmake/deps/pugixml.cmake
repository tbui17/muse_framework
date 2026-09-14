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
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Reviewed pugixml source recipe. The archive pin and expected layout live in
# dependencies.lock.cmake; this file only materialises the checked-in target contract.
function(pugixml_Populate local_path)
    muse_dependency_payload(pugixml "${local_path}")

    set(source_dir "${local_path}/pugixml/src")
    if (NOT TARGET pugixml)
        add_library(pugixml STATIC
            "${source_dir}/pugixml.cpp")
        target_include_directories(pugixml PUBLIC "${source_dir}")
        set_target_properties(pugixml PROPERTIES
            POSITION_INDEPENDENT_CODE ON
            UNITY_BUILD OFF)
    endif()

    set_property(GLOBAL PROPERTY pugixml_SOURCE_DIR "${local_path}")
endfunction()
