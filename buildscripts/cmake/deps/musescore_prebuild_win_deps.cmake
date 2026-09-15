# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Reviewed recipe for the Windows prebuilt native dependencies (zlib, libsndfile).
# The immutable codeload archive of the pinned revision, its SHA-256 and the expected
# layout live in dependencies.lock.cmake; the tree is extracted to <local_path>/source.

function(musescore_prebuild_win_deps_Populate local_path)
    muse_dependency_payload(musescore_prebuild_win_deps "${local_path}")

    set_property(GLOBAL PROPERTY musescore_prebuild_win_deps_SOURCE_DIR "${local_path}/source")
endfunction()
