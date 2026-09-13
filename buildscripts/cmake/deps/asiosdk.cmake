# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Reviewed recipe for the ASIO SDK (Windows only). The SDK zip is pinned with its
# SHA-256 in dependencies.lock.cmake; it is extracted to <local_path>/ASIOSDK.

function(asiosdk_Populate local_path)
    muse_dependency_payload(asiosdk "${local_path}")
endfunction()
