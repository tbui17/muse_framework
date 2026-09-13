# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Reviewed recipe for the license notice payloads.
#
# Three components that ship inside the Windows package carry no notice file in
# their own pinned payload, and the Qt binary package does not carry the license
# texts at all, so their exact texts are fetched from separate immutable archives
# listed in dependencies.lock.cmake:
#
#   * zlib 1.2.8 (zlibstat.lib in musescore_prebuild_win_deps); zlib 1.2.8 ships no
#     LICENSE file, the license text is the statement in its root README.
#   * libsndfile 1.0.25 (libsndfile-1.dll in musescore_prebuild_win_deps).
#   * OpenSSL 1.1.1c (libcrypto/libssl DLLs shipped next to libsndfile).
#   * Qt 6.10.2 shipped modules (qtbase, qtdeclarative, qtsvg, qttools,
#     qttranslations, qt5compat, qtnetworkauth, qtshadertools, qtwebsockets), whose
#     source archives provide the per-module LICENSES, REUSE and attribution records.
#
# The payloads carry no build products: only notice texts are installed from them.

function(license_notices_Populate local_path)
    muse_dependency_payload(license_notices "${local_path}")

    set_property(GLOBAL PROPERTY license_notices_SOURCE_DIR "${local_path}")
endfunction()
