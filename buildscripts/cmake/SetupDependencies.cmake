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

if (MUSE_MODULE_AUDIO_EXPORT)
    populate(fdk-aac)

    if (MUSE_APP_INSTALL_RESOURCES_LOCATION)
        # The FDK AAC license text is NOTICE; MODULE_LICENSE_FRAUNHOFER in the same payload is
        # an empty marker file, so only the real text is installed.
        get_property(fdk_aac_src_dir GLOBAL PROPERTY fdk-aac_SOURCE_DIR)
        muse_install_license_notice(fdk-aac "${fdk_aac_src_dir}" "NOTICE")
    endif()
endif()

if (MUSE_APP_INSTALL_RESOURCES_LOCATION)
    # Source references for the components whose notices are installed above and in the module
    # CMakeLists (see every muse_install_license_notice call site).
    muse_install_source_index(
        "framework/draw/thirdparty/freetype/freetype-2.14.1|freetype 2.14.1, in-tree"
        "framework/audio/thirdparty/fluidsynth/fluidsynth-2.3.3|FluidSynth 2.3.3, in-tree"
        "framework/audio/thirdparty/lame|lame, in-tree"
        "framework/audio/thirdparty/flac/flac-1.4.3|FLAC 1.4.3, in-tree"
        "framework/audio/thirdparty/opus/opus-1.5.2|Opus 1.5.2, in-tree"
        "framework/audio/thirdparty/opusenc/libopusenc-0.2.1|libopusenc 0.2.1, in-tree"
        "framework/audio/thirdparty/stb/stb_vorbis.c|stb_vorbis v1.22, in-tree"
        "framework/global/thirdparty/kors_*|kors modules, in-tree"
        "framework/global/thirdparty/utfcpp|utf8cpp, in-tree"
        "framework/global/thirdparty/pugixml|pugixml, license text inside pugixml.hpp"
        "framework/global/thirdparty/picojson|picojson, license text inside picojson.h"
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
