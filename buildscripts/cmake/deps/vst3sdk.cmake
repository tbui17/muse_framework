# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Reviewed recipe for the VST 3 SDK 3.7.12_build_20. The SDK is delivered by upstream as
# three separate repositories which must be nested as siblings (base/, pluginterfaces/,
# public.sdk/) for the SDK's internal includes to resolve. All three payloads are pinned
# with their SHA-256 in dependencies.lock.cmake and extracted directly into <local_path>.

function(vst3sdk_Populate local_path)
    muse_dependency_payload(vst3sdk "${local_path}")
endfunction()
