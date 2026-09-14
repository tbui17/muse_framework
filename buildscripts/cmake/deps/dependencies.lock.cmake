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
# Existing pins were verified on 2026-09-13 by downloading each payload from the URL recorded
# next to it and hashing the bytes. The audio and draw pins added in this migration were verified
# the same way on 2026-09-14. Each pin matches the corresponding recipe in the upstream
# musescore/muse_deps revision daedf3e1b761a1af8035f1a2dbf88cf581f7c62
# (recipes/<name>/spec.cmake); expected layouts were verified against those downloads.
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

# --- Ogg 1.3.5 (MUSE_MODULE_AUDIO_EXPORT) -------------------------------------------
set(MUSE_DEP_ogg_VERSION "1.3.5")
set(MUSE_DEP_ogg_PAYLOADS
    "single-root|libogg-1.3.5|https://github.com/xiph/ogg/releases/download/v1.3.5/libogg-1.3.5.tar.gz|0eb4b4b9420a0f51db142ba3f9c64b333f826532dc0f48c6410ae51f4799b664"
)
set(MUSE_DEP_ogg_EXPECTED
    "libogg-1.3.5/COPYING"
    "libogg-1.3.5/CMakeLists.txt"
    "libogg-1.3.5/include/ogg/ogg.h"
)
# --- FLAC 1.4.3 (MUSE_MODULE_AUDIO_EXPORT) ------------------------------------------
set(MUSE_DEP_flac_VERSION "1.4.3")
set(MUSE_DEP_flac_PAYLOADS
    "single-root|flac-1.4.3|https://github.com/xiph/flac/releases/download/1.4.3/flac-1.4.3.tar.xz|6c58e69cd22348f441b861092b825e591d0b822e106de6eb0ee4d05d27205b70"
)
set(MUSE_DEP_flac_EXPECTED
    "flac-1.4.3/COPYING.Xiph"
    "flac-1.4.3/COPYING.GPL"
    "flac-1.4.3/COPYING.LGPL"
    "flac-1.4.3/CMakeLists.txt"
    "flac-1.4.3/include/FLAC/all.h"
)

# --- LAME 3.100 (MUSE_MODULE_AUDIO_EXPORT) -------------------------------------------
set(MUSE_DEP_lame_VERSION "3.100")
set(MUSE_DEP_lame_PAYLOADS
    "single-root|lame-3.100|https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz|ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e"
)
set(MUSE_DEP_lame_EXPECTED
    "lame-3.100/COPYING"
    "lame-3.100/include/lame.h"
    "lame-3.100/libmp3lame/bitstream.c"
)

# --- Opus 1.5.2 (MUSE_MODULE_AUDIO_EXPORT) -------------------------------------------
set(MUSE_DEP_opus_VERSION "1.5.2")
set(MUSE_DEP_opus_PAYLOADS
    "single-root|opus-1.5.2|https://github.com/xiph/opus/releases/download/v1.5.2/opus-1.5.2.tar.gz|65c1d2f78b9f2fb20082c38cbe47c951ad5839345876e46941612ee87f9a7ce1"
)
set(MUSE_DEP_opus_EXPECTED
    "opus-1.5.2/CMakeLists.txt"
    "opus-1.5.2/COPYING"
    "opus-1.5.2/include/opus.h"
)

# --- libopusenc 0.2.1 (MUSE_MODULE_AUDIO_EXPORT) ------------------------------------
set(MUSE_DEP_opusenc_VERSION "0.2.1")
set(MUSE_DEP_opusenc_PAYLOADS
    "single-root|libopusenc-0.2.1|https://github.com/xiph/libopusenc/archive/v0.2.1.tar.gz|56952a926ff962c62a468b43cc8506c069bda767cade4dc92824b74edd570d68"
)
set(MUSE_DEP_opusenc_EXPECTED
    "libopusenc-0.2.1/COPYING"
    "libopusenc-0.2.1/include/opusenc.h"
    "libopusenc-0.2.1/src/opusenc.c"
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

# --- FreeType 2.14.1 (MUSE_MODULE_DRAW) ---------------------------------------------
set(MUSE_DEP_freetype_VERSION "2.14.1")
set(MUSE_DEP_freetype_PAYLOADS
    "single-root|freetype-2.14.1|https://download.savannah.gnu.org/releases/freetype/freetype-2.14.1.tar.xz|32427e8c471ac095853212a37aef816c60b42052d4d9e48230bab3bdf2936ccc"
)
set(MUSE_DEP_freetype_EXPECTED
    "freetype-2.14.1/CMakeLists.txt"
    "freetype-2.14.1/LICENSE.TXT"
    "freetype-2.14.1/docs/FTL.TXT"
    "freetype-2.14.1/docs/GPLv2.TXT"
    "freetype-2.14.1/include/freetype/freetype.h"
    "freetype-2.14.1/include/ft2build.h"
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



# --- Source-delivery dependencies compiled or included by muse_global --------------
# These pins mirror the current MuseDeps source recipes. Their checked-in recipes
# expose the same target and source-directory contracts without executing remote
# CMake at configure time.
set(MUSE_DEP_picojson_VERSION "111c9be")
set(MUSE_DEP_picojson_PAYLOADS
    "single-root|picojson|https://github.com/kazuho/picojson/archive/111c9be5188f7350c2eac9ddaedd8cca3d7bf394.tar.gz|671f89832a17e9e71398f80c0a326afa2ebe81f4c26d5a9992e1fcd0888ae151"
)
set(MUSE_DEP_picojson_EXPECTED
    "picojson/LICENSE"
    "picojson/picojson.h"
)

set(MUSE_DEP_pugixml_VERSION "1.15")
set(MUSE_DEP_pugixml_PAYLOADS
    "single-root|pugixml|https://github.com/zeux/pugixml/releases/download/v1.15/pugixml-1.15.tar.gz|655ade57fa703fb421c2eb9a0113b5064bddb145d415dd1f88c79353d90d511a"
)
set(MUSE_DEP_pugixml_EXPECTED
    "pugixml/LICENSE.md"
    "pugixml/src/pugixml.cpp"
    "pugixml/src/pugixml.hpp"
)

set(MUSE_DEP_utfcpp_VERSION "4.1.1")
set(MUSE_DEP_utfcpp_PAYLOADS
    "single-root|utfcpp|https://github.com/nemtrif/utfcpp/archive/refs/tags/v4.1.1.tar.gz|1ca68016f0abc24172998e39ce0d8f8e2b7a26f7579a0ff85d4e1b9a7aea56f8"
)
set(MUSE_DEP_utfcpp_EXPECTED
    "utfcpp/LICENSE"
    "utfcpp/source/utf8.h"
)

# --- License notice texts (no build products; see deps/license_notices.cmake) ------
# Three components that ship inside the Windows package carry no notice file in their
# own pinned payload, and the Qt binary package does not carry the license texts at all,
# so the exact texts of the shipped versions are pinned separately here:
#   * zlib 1.2.8, identified by ZLIB_VERSION in the prebuilt payload's include/zlib/zlib.h;
#     zlib 1.2.8 ships no LICENSE file, its license statement is the text in README.
#   * libsndfile 1.0.25, identified by the version string in the shipped libsndfile-1.dll.
#   * OpenSSL 1.1.1c, identified by the version string in the shipped libcrypto/libssl DLLs.
#   * Qt 6.10.2, the source archives of the shipped modules (qtbase, qtdeclarative, qtsvg,
#     qttools, qttranslations, qt5compat, qtnetworkauth, qtshadertools, qtwebsockets), whose
#     LICENSES sets, REUSE/attribution files and third-party notices are installed per module.
#   * GNU FreeFont 20120503, whose GPL-3.0 text and font-exception README ship with the fonts
#     that are embedded in the executable; the shipped FreeSans.ttf/FreeSerif.ttf are
#     byte-identical to this release asset.
# Every hash below was verified on 2026-09-13 by downloading the URL and hashing the bytes;
# the Qt archive hash was additionally checked against the checksum published next to it.
set(MUSE_DEP_license_notices_VERSION "2026-09-13")
set(MUSE_DEP_license_notices_PAYLOADS
    "single-root|zlib-1.2.8|https://zlib.net/fossils/zlib-1.2.8.tar.gz|36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d"
    "single-root|libsndfile-1.0.25|https://github.com/libsndfile/libsndfile/archive/refs/tags/1.0.25.tar.gz|5fc65b356f1458a36a094d3ae89a3e267057e7dea8e288f956f0c6803611cd5b"
    "single-root|openssl-1.1.1c|https://www.openssl.org/source/old/1.1.1/openssl-1.1.1c.tar.gz|f6fb3079ad15076154eda9413fed42877d668e7069d9b87396d0804fdb3f4c90"
    "single-root|freefont-20120503|https://ftp.gnu.org/gnu/freefont/freefont-ttf-20120503.zip|7c85baf1bf82a1a1845d1322112bc6ca982221b484e3b3925022e25b5cae89af"
    "single-root|qtbase-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qtbase-everywhere-src-6.10.2.tar.xz|aeb78d29291a2b5fd53cb55950f8f5065b4978c25fb1d77f627d695ab9adf21e"
    "single-root|qtdeclarative-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qtdeclarative-everywhere-src-6.10.2.tar.xz|a249914ff66cdcdbf0df8b5ffad997a2ee6dce01cc17d43c6cc56fdc1d0f4b0f"
    "single-root|qtsvg-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qtsvg-everywhere-src-6.10.2.tar.xz|f07ff80f38caf235187200345392ca7479445ddf49a36c3694cd52a735dad6e1"
    "single-root|qttools-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qttools-everywhere-src-6.10.2.tar.xz|1e3d2c07c1fd76d2425c6eaeeaa62ffaff5f79210c4e1a5bc2a6a9db668d5b24"
    "single-root|qttranslations-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qttranslations-everywhere-src-6.10.2.tar.xz|b3b3813bc9d76b545716dc8b6e659fa71b6e2bc14569e9fab6dab8b30650a644"
    "single-root|qt5compat-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qt5compat-everywhere-src-6.10.2.tar.xz|3fa418f0fac02eb9efc5f762fbe25f20647b0ebb7fa92faf07e6de85044161c2"
    "single-root|qtnetworkauth-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qtnetworkauth-everywhere-src-6.10.2.tar.xz|4f29fd9e4b505f5714fc42296b04c701f66ced185c49de4d520cb8de4b1981b3"
    "single-root|qtshadertools-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qtshadertools-everywhere-src-6.10.2.tar.xz|18d9dbbc4f7e6e96e6ed89a9965dc032e2b58158b65156c035537826216716c9"
    "single-root|qtwebsockets-everywhere-src-6.10.2|https://download.qt.io/official_releases/qt/6.10/6.10.2/submodules/qtwebsockets-everywhere-src-6.10.2.tar.xz|eccc751bea509ef656d20029693987a0fc03c58e21c38f1351480f3c8eb42ebd"
)
set(MUSE_DEP_license_notices_EXPECTED
    "zlib-1.2.8/README"
    "libsndfile-1.0.25/COPYING"
    "openssl-1.1.1c/LICENSE"
    "qtbase-everywhere-src-6.10.2/LICENSES/LGPL-3.0-only.txt"
    "qtbase-everywhere-src-6.10.2/LICENSES/GPL-3.0-only.txt"
    "qtbase-everywhere-src-6.10.2/LICENSES/Qt-GPL-exception-1.0.txt"
    "freefont-20120503/COPYING"
    "freefont-20120503/README"
    "qtbase-everywhere-src-6.10.2/src/dbus/LICENSE.LIBDBUS-1.txt"
    "qtbase-everywhere-src-6.10.2/src/3rdparty/freetype/LICENSE.txt"
    "qtbase-everywhere-src-6.10.2/src/3rdparty/harfbuzz-ng/COPYING"
    "qtbase-everywhere-src-6.10.2/src/3rdparty/libpng/LICENSE"
    "qtbase-everywhere-src-6.10.2/src/3rdparty/zlib/LICENSE"
    "qtbase-everywhere-src-6.10.2/LICENSES/LGPL-3.0-only.txt"
    "qtdeclarative-everywhere-src-6.10.2/src/3rdparty/yoga/LICENSE"
    "qtsvg-everywhere-src-6.10.2/src/svg/LICENSE.XSVG.txt"
    "qttools-everywhere-src-6.10.2/src/assistant/qlitehtml/src/3rdparty/litehtml/LICENSE"
    "qttools-everywhere-src-6.10.2/src/qdoc/catch/LICENSE.CATCH.txt"
    "qt5compat-everywhere-src-6.10.2/src/core5/codecs/LICENSE.QBIG5CODEC.txt"
    "qtshadertools-everywhere-src-6.10.2/src/3rdparty/glslang/LICENSE.txt"
    "qtshadertools-everywhere-src-6.10.2/src/3rdparty/SPIRV-Cross/LICENSE"
    "qtwebsockets-everywhere-src-6.10.2/LICENSES/LGPL-3.0-only.txt"
    "qtnetworkauth-everywhere-src-6.10.2/LICENSES/BSD-3-Clause.txt"
    "qttranslations-everywhere-src-6.10.2/LICENSES/GPL-3.0-only.txt"
)
