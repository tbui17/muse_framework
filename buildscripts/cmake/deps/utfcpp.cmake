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

# Reviewed utf8cpp source recipe. The archive pin and expected layout live in
# dependencies.lock.cmake; this file only materialises the checked-in target contract.
function(utfcpp_Populate local_path)
    muse_dependency_payload(utfcpp "${local_path}")

    set(source_dir "${local_path}/utfcpp/source")
    if (NOT TARGET utfcpp)
        add_library(utfcpp INTERFACE IMPORTED GLOBAL)
        set_target_properties(utfcpp PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${source_dir}")
    endif()

    # Keep the property compatible with the current MuseDeps consumer contract.
    set_property(GLOBAL PROPERTY utfcpp_SOURCE_DIR "${local_path}")
endfunction()
