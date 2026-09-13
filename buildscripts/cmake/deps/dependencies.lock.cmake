# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Pinned dependency payloads: the single authoritative location for every URL and
# expected SHA-256 used by the reviewed recipes in this directory.
#
# Rules for this file:
#   * URLs must be immutable: a commit/tag archive or a release asset, never a branch.
#   * Every payload needs a checked-in SHA-256 that was verified by downloading the
#     payload and hashing it, not by copying whatever the remote returned at runtime.
#   * A dependency is validated by EXPECTED; the paths below are relative to the
#     dependency output directory and are how an incomplete cache is detected.
#
# Payload entry format: "<mode>|<destination>|<url>|<sha256>"
#   mode         currently only "single-root": the archive must contain exactly one
#                top-level directory, which becomes <output_dir>/<destination>
#   destination  directory created from the archive's single root
#
# Expected entry format: "<destination-relative path>" that must exist after fetching.
#
# Every hash below was verified on 2026-09-13 by downloading the payload from the URL
# recorded next to it and hashing the bytes, and each one matches the corresponding pin in
# the upstream recipes at musescore/muse_deps daedf3e1b761a1af80335f1a2dbf88cf581f7c62
# (recipes/<name>/spec.cmake). Expected layouts were verified against the same downloads.
# A changed upstream payload therefore fails the build instead of entering it silently.

# --- musescore_prebuild_win_deps (Windows prebuilt zlib + libsndfile) --------------
# Immutable codeload archive of the pinned revision (the repository has no nested
# submodules), used instead of a mutable GIT_TAG HEAD checkout.
set(MUSE_DEP_musescore_prebuild_win_deps_VERSION "446574e2ba2b9a3c9664b416b28ff63ce40a74e0")
set(MUSE_DEP_musescore_prebuild_win_deps_PAYLOADS
    "single-root|source|https://codeload.github.com/musescore/musescore_prebuild_win_deps/tar.gz/446574e2ba2b9a3c9664b416b28ff63ce40a74e0|70a264d92fb7efcab109eb72aa85758d251b2c321ea9d1e2be413693498fd760"
)
set(MUSE_DEP_musescore_prebuild_win_deps_EXPECTED
    "source/include/zlib/zlib.h"
    "source/include/sndfile.h"
    "source/libx64/zlibstat.lib"
    "source/libx64/libsndfile-1.lib"
)

# --- fdk-aac 2.0.3 (MUSE_MODULE_AUDIO_EXPORT) ---------------------------------------
set(MUSE_DEP_fdk-aac_VERSION "2.0.3")
set(MUSE_DEP_fdk-aac_PAYLOADS
    "single-root|fdk-aac-2.0.3|https://github.com/mstorsjo/fdk-aac/archive/refs/tags/v2.0.3.tar.gz|e25671cd96b10bad896aa42ab91a695a9e573395262baed4e4a2ff178d6a3a78"
)
set(MUSE_DEP_fdk-aac_EXPECTED
    "fdk-aac-2.0.3/CMakeLists.txt"
    "fdk-aac-2.0.3/fdk-aac.pc.in"
)

# --- ASIO SDK 2.3.4 / 2025-10-15 (MUSE_MODULE_AUDIO_ASIO, Windows) ------------------
# The ASIO SDK is distributed as a zip inside muse_deps; the commit below is the
# immutable revision that shipped this exact archive (sha256 verified).
set(MUSE_DEP_asiosdk_VERSION "2.3.4")
set(MUSE_DEP_asiosdk_PAYLOADS
    "single-root|ASIOSDK|https://raw.githubusercontent.com/musescore/muse_deps/c9a299e19df04e40435d1c4649548c69ce152bd8/asiosdk/ASIO-SDK_2.3.4_2025-10-15/ASIO-SDK_2.3.4_2025-10-15.zip|d5ebf0c20dd2c5f43771fd0c1418f4b361bf52434ee670097cfa6b3a335e2eca"
)
set(MUSE_DEP_asiosdk_EXPECTED
    "ASIOSDK/common/asio.h"
    "ASIOSDK/common/asiodrvr.h"
    "ASIOSDK/host/asiodrivers.h"
    "ASIOSDK/host/pc/asiolist.h"
)

# --- HarfBuzz 12.3.0 (MUSE_MODULE_DRAW) --------------------------------------------
set(MUSE_DEP_harfbuzz_VERSION "12.3.0")
set(MUSE_DEP_harfbuzz_PAYLOADS
    "single-root|harfbuzz|https://github.com/harfbuzz/harfbuzz/releases/download/12.3.0/harfbuzz-12.3.0.tar.xz|8660ebd3c27d9407fc8433b5d172bafba5f0317cb0bb4339f28e5370c93d42b7"
)
set(MUSE_DEP_harfbuzz_EXPECTED
    "harfbuzz/CMakeLists.txt"
    "harfbuzz/src/harfbuzz.cc"
    "harfbuzz/src/hb-ft.h"
)

# --- KDDockWidgets 2.4 (MUSE_MODULE_DOCKWINDOW_KDDOCKWIDGETS_V2) -------------------
# Pinned to the reviewed commit instead of the moving "2.4" branch that the previous
# recipe cloned with --depth 1.
set(MUSE_DEP_kddockwidgets_VERSION "2.4")
set(MUSE_DEP_kddockwidgets_PAYLOADS
    "single-root|kddockwidgets|https://github.com/musescore/KDDockWidgets/archive/662d74a6d3c168dbc31883e56039539d865a316a.tar.gz|df1d9fa956c1e22228b79354feee335ba4f33b690af166749ec06e3ff6b604e2"
)
set(MUSE_DEP_kddockwidgets_EXPECTED
    "kddockwidgets/CMakeLists.txt"
    "kddockwidgets/src/kdbindings.cmake"
)

# --- VST 3 SDK 3.7.12_build_20 (MUSE_MODULE_VST) ----------------------------------
# The SDK is split across three upstream repositories that must be nested as siblings
# below VST3_SDK_PATH (base/, pluginterfaces/, public.sdk/). The previous recipe
# downloaded a single pre-packed 7z that no longer exists in muse_deps.
set(MUSE_DEP_vst3sdk_VERSION "3.7.12_build_20")
set(MUSE_DEP_vst3sdk_PAYLOADS
    "single-root|base|https://github.com/steinbergmedia/vst3_base/archive/f0998e7b8424b32ba275cf4218aa56beef29821c.tar.gz|5460f4d09bc65fbbc23315c6900dda33eb96a7a3f1720d1d7387592a69bc24ef"
    "single-root|pluginterfaces|https://github.com/steinbergmedia/vst3_pluginterfaces/archive/151ecde4d6ee1c457dcce848342b162461944fe6.tar.gz|e7bb5dc1701c2c136d0902d458533ef0fa9cf720c088f176659d017780ffda3a"
    "single-root|public.sdk|https://github.com/steinbergmedia/vst3_public_sdk/archive/3fce096d6ee575479753f1aab23033d2e2ffdc6e.tar.gz|2915be92fa70eda43b99ee492957b9334ae7cc6156f26f25bda952fc34248408"
)
set(MUSE_DEP_vst3sdk_EXPECTED
    "base/thread/source/flock.cpp"
    "base/source/fobject.h"
    "pluginterfaces/base/funknown.h"
    "pluginterfaces/vst/ivstmidicontrollers.h"
    "public.sdk/source/vst/hosting/module.h"
    "public.sdk/source/vst/hosting/module_win32.cpp"
    "public.sdk/source/vst/utility/stringconvert.h"
)
