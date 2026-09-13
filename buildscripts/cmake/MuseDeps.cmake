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

# Dependency bootstrap.
#
# Recipe location and payload location are separate on purpose:
#   * reviewed recipes are checked in under buildscripts/cmake/deps and are never
#     downloaded from a remote branch at configure time
#   * pinned payload URLs and SHA-256 live in buildscripts/cmake/deps/dependencies.lock.cmake
#   * payloads are materialised under the build tree, one directory per dependency
#     (FETCHCONTENT_BASE_DIR/<name>), so the vendored recipe directory stays read-only
#
# See DependencyPayload.cmake for the download/verify/extract requirements.

include("${CMAKE_CURRENT_LIST_DIR}/DependencyPayload.cmake")

function(populate name)
    muse_dependency_output_dir(${name} local_path)

    # Reviewed recipe + explicit check that it defines <name>_Populate.
    muse_dependency_populate(${name} "${local_path}")

    get_property(include_dirs GLOBAL PROPERTY ${name}_INCLUDE_DIRS)
    get_property(libraries GLOBAL PROPERTY ${name}_LIBRARIES)
    get_property(install_libraries GLOBAL PROPERTY ${name}_INSTALL_LIBRARIES)

    set(${name}_INCLUDE_DIRS ${include_dirs} PARENT_SCOPE)
    set(${name}_LIBRARIES ${libraries} PARENT_SCOPE)
    set(${name}_INSTALL_LIBRARIES ${install_libraries} PARENT_SCOPE)

endfunction()
