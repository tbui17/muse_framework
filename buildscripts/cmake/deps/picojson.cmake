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

# Reviewed picojson source recipe. The archive pin and expected layout live in
# dependencies.lock.cmake; this file applies the checked-in framework patch after
# the verified payload is materialised.
function(picojson_Populate local_path)
    muse_dependency_payload(picojson "${local_path}")

    set(source_dir "${local_path}/picojson")
    if (NOT EXISTS "${source_dir}/.muse-picojson-patched")
        find_program(_muse_git git)
        if (NOT _muse_git)
            message(FATAL_ERROR "[picojson] git is required to apply the checked-in framework patch")
        endif()
        execute_process(
            COMMAND "${_muse_git}" apply --whitespace=nowarn
                "${MUSE_DEPS_RECIPE_DIR}/picojson.patch"
            WORKING_DIRECTORY "${source_dir}"
            RESULT_VARIABLE _patch_result
            OUTPUT_VARIABLE _patch_output
            ERROR_VARIABLE _patch_error)
        if (NOT _patch_result EQUAL 0)
            message(FATAL_ERROR
                "[picojson] checked-in patch failed for the verified source payload:\n"
                "${_patch_output}\n${_patch_error}")
        endif()
        file(WRITE "${source_dir}/.muse-picojson-patched" "picojson framework patch applied\n")
    endif()

    if (NOT TARGET picojson)
        add_library(picojson INTERFACE IMPORTED GLOBAL)
        set_target_properties(picojson PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${source_dir}")
    endif()

    set_property(GLOBAL PROPERTY picojson_SOURCE_DIR "${local_path}")
endfunction()
