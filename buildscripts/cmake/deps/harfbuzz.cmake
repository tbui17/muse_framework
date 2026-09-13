# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Reviewed recipe for HarfBuzz. The upstream 12.3.0 release tarball is pinned with its
# SHA-256 in dependencies.lock.cmake and is extracted to <local_path>/harfbuzz. The
# MuseScore build wrapper that compiles the amalgamated harfbuzz.cc is checked in at
# framework/draw/thirdparty/harfbuzz.

function(harfbuzz_Populate local_path)
    muse_dependency_payload(harfbuzz "${local_path}")
endfunction()
