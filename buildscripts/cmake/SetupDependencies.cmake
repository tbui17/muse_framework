# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2024 MuseScore Limited
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

message(STATUS "Setup dependencies")

include(MuseDeps)
if (MUSE_APP_INSTALL_RESOURCES_LOCATION)
    include(SetupLicenseNotices)
endif()
populate(picojson)
populate(pugixml)
populate(utfcpp)

if (MUSE_MODULE_AUDIO_EXPORT)
    # These targets mirror current-main MuseDeps metadata. Keep dependency order explicit because
    # FLAC and libopusenc consume the canonical Ogg target, while libopusenc also consumes Opus.
    if (NOT MUSE_USE_SYSTEM_FLAC OR NOT MUSE_USE_SYSTEM_OPUSENC)
        populate(ogg)
    endif()

    if (MUSE_USE_SYSTEM_OPUS)
        find_package(Opus QUIET)
        if (OPUS_FOUND)
            if (TARGET opus AND NOT TARGET Opus::opus)
                add_library(Opus::opus ALIAS opus)
            endif()
        endif()
        if (NOT TARGET Opus::opus)
            find_package(PkgConfig QUIET)
            if (PkgConfig_FOUND)
                pkg_check_modules(opus QUIET IMPORTED_TARGET opus)
                if (TARGET PkgConfig::opus)
                    add_library(Opus::opus ALIAS PkgConfig::opus)
                endif()
            endif()
        endif()
        if (NOT TARGET Opus::opus)
            message(WARNING "Set MUSE_USE_SYSTEM_OPUS=ON, but system opus was not usable; the pinned source will be used")
            populate(opus)
        endif()
    elseif (NOT MUSE_USE_SYSTEM_OPUSENC)
        populate(opus)
    endif()

    if (NOT MUSE_USE_SYSTEM_FLAC)
        populate(flac)
    endif()
    if (NOT MUSE_USE_SYSTEM_LAME)
        populate(lame)
    endif()
    if (NOT MUSE_USE_SYSTEM_OPUSENC)
        populate(opusenc)
    endif()
endif()

if (MUSE_MODULE_AUDIO_EXPORT)
    populate(fdk-aac)
endif()

if (MUSE_MODULE_DRAW)
    include("${CMAKE_CURRENT_LIST_DIR}/../../framework/draw/cmake/SetupFreeType.cmake")
    include("${CMAKE_CURRENT_LIST_DIR}/../../framework/draw/cmake/SetupHarfBuzz.cmake")
endif()

if (MUSE_APP_INSTALL_RESOURCES_LOCATION)
    get_property(_picojson_source_dir GLOBAL PROPERTY picojson_SOURCE_DIR)
    muse_install_license_notice(picojson "${_picojson_source_dir}/picojson" "LICENSE")

    get_property(_pugixml_source_dir GLOBAL PROPERTY pugixml_SOURCE_DIR)
    muse_install_license_notice(pugixml "${_pugixml_source_dir}/pugixml" "LICENSE.md")

    get_property(_utfcpp_source_dir GLOBAL PROPERTY utfcpp_SOURCE_DIR)
    muse_install_license_notice(utf8cpp "${_utfcpp_source_dir}/utfcpp" "LICENSE")

    if (MUSE_MODULE_AUDIO_EXPORT)
        get_property(_ogg_source_dir GLOBAL PROPERTY ogg_SOURCE_DIR)
        if (_ogg_source_dir)
            muse_install_license_notice(ogg "${_ogg_source_dir}" "COPYING")
        endif()

        get_property(_flac_source_dir GLOBAL PROPERTY flac_SOURCE_DIR)
        if (_flac_source_dir)
            muse_install_license_notice(flac "${_flac_source_dir}" "COPYING.Xiph" "COPYING.GPL" "COPYING.LGPL")
        endif()

        get_property(_lame_source_dir GLOBAL PROPERTY lame_SOURCE_DIR)
        if (_lame_source_dir)
            muse_install_license_notice(lame "${_lame_source_dir}" "COPYING")
        endif()

        get_property(_opus_source_dir GLOBAL PROPERTY opus_SOURCE_DIR)
        if (_opus_source_dir)
            muse_install_license_notice(opus "${_opus_source_dir}" "COPYING")
        endif()

        get_property(_opusenc_source_dir GLOBAL PROPERTY opusenc_SOURCE_DIR)
        if (_opusenc_source_dir)
            muse_install_license_notice(libopusenc "${_opusenc_source_dir}" "COPYING")
        endif()

        get_property(_fdk_aac_source_dir GLOBAL PROPERTY fdk-aac_SOURCE_DIR)
        muse_install_license_notice(fdk-aac "${_fdk_aac_source_dir}" "NOTICE")
    endif()
endif()


if (MUSE_MODULE_DOCKWINDOW_KDDOCKWIDGETS_V2)
    populate(kddockwidgets)

    if (MUSE_APP_INSTALL_RESOURCES_LOCATION)
        # KDDockWidgets is offered under GPL-2.0 or GPL-3.0 (KDAB); the runtime components it
        # embeds (nlohmann JSON, KDBindings) are MIT. Upstream installs these files only when
        # KDDockWidgets is the root project, which it is not when it is fetched as a dependency.
        get_property(kddockwidgets_src_dir GLOBAL PROPERTY kddockwidgets_SOURCE_DIR)
        muse_install_license_notice(kddockwidgets "${kddockwidgets_src_dir}/kddockwidgets"
            "LICENSE.txt"
            "LICENSE.GPL.txt"
            "3RDPARTY.md"
            "LICENSES/GPL-2.0-only.txt"
            "LICENSES/GPL-3.0-only.txt"
            "LICENSES/MIT.txt"
            "LICENSES/BSD-3-Clause.txt"
            "LICENSES/LicenseRef-FlutterBSD.txt"
            "src/3rdparty/nlohmann/nlohmann/LICENSE.MIT"
        )
    endif()
endif()


if (MUSE_APP_INSTALL_RESOURCES_LOCATION)
    # Source references for the components whose notices are installed above and in the module
    # CMakeLists (see every muse_install_license_notice call site).
    muse_install_source_index(
        "freetype/freetype-2.14.1|freetype 2.14.1, pinned source payload"
        "harfbuzz/harfbuzz|HarfBuzz 12.3.0, pinned source payload"
        "framework/audio/thirdparty/fluidsynth/fluidsynth-2.3.3|FluidSynth 2.3.3, in-tree"
        "ogg/libogg-1.3.5|Ogg 1.3.5, pinned source payload"
        "lame/lame-3.100|LAME 3.100, pinned source payload"
        "flac/flac-1.4.3|FLAC 1.4.3, pinned source payload"
        "opus/opus-1.5.2|Opus 1.5.2, pinned source payload"
        "opusenc/libopusenc-0.2.1|libopusenc 0.2.1, pinned source payload"
        "fdk-aac/fdk-aac-2.0.3|fdk-aac 2.0.3, pinned source payload"
        "framework/audio/thirdparty/stb/stb_vorbis.c|stb_vorbis v1.22, in-tree"
        "framework/global/thirdparty/kors_*|kors modules, in-tree"
        "picojson|picojson 111c9be, pinned source payload"
        "pugixml/src|pugixml 1.15, pinned source payload"
        "utfcpp/source|utf8cpp 4.1.1, pinned source payload"
        "framework/dockwindow/thirdparty/KDDockWidgets|KDDockWidgets 1.4.95, in-tree"
        "src/braille/thirdparty/liblouis|liblouis 3.24.0, in-tree"
        "src/engraving/thirdparty/intervaltree|intervaltree, in-tree"
        "src/engraving/thirdparty/dtl|dtl, in-tree"
        "src/importexport/midi/thirdparty/beatroot|beatroot, in-tree"
        "src/importexport/capella/thirdparty/rtf2html|rtf2html, in-tree"
        "src/importexport/mei/thirdparty/libmei|Verovio libmei generated sources, in-tree"
        "src/importexport/mnx|mnxdom, fetched at commit e7c947bf768caccf315426dcae0dfac02caf738b"
        "fonts|embedded fonts and their OFL texts, in-tree"
        "fonts/FreeSans.ttf, fonts/FreeSerif.ttf|GNU FreeFont 20120503, byte-identical to the pinned release asset"
        "Qt module sources|notices and attribution installed per shipped module from the pinned Qt 6.10.2 archives"
        "Qt binary packages|Qt 6.10.2 win64_msvc2022_64, deployed by windeployqt"
    )
endif()
