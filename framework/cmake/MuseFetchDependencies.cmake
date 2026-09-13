# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Windows prebuilt native dependencies (zlib, libsndfile).
#
# The payload is the immutable codeload archive of a pinned revision; its URL and SHA-256
# are recorded in buildscripts/cmake/deps/dependencies.lock.cmake and its expected layout
# is validated by the reviewed recipe (buildscripts/cmake/deps/musescore_prebuild_win_deps.cmake).
# It is fetched into the build tree, never into the source tree, and a cold configure never
# follows the moving HEAD of a remote branch.
#
# Layout provided by the pinned revision:
#   <root>/include/zlib/zlib.h, <root>/include/sndfile.h
#   <root>/libx64/zlibstat.lib, <root>/libx64/libsndfile-1.lib

include(DependencyPayload)

if (OS_IS_WIN)
    muse_dependency_output_dir(musescore_prebuild_win_deps _prebuilt_win_deps_output_dir)
    muse_dependency_populate(musescore_prebuild_win_deps "${_prebuilt_win_deps_output_dir}")

    get_property(DEPENDENCIES_DIR GLOBAL PROPERTY musescore_prebuild_win_deps_SOURCE_DIR)

    set(DEPENDENCIES_LIB_DIR ${DEPENDENCIES_DIR}/libx64)
    set(DEPENDENCIES_INC ${DEPENDENCIES_DIR}/include)

    message(STATUS "Windows prebuilt dependencies: ${DEPENDENCIES_DIR}")

    if (MUSE_APP_INSTALL_RESOURCES_LOCATION)
        # The pinned prebuilt payload carries no notice file, and the Qt binary package does not
        # include the license texts, so the exact texts of the shipped versions come from the
        # separate immutable archives pinned under license_notices in the lock file.
        include(SetupLicenseNotices)
        muse_dependency_output_dir(license_notices _license_notices_output_dir)
        muse_dependency_populate(license_notices "${_license_notices_output_dir}")
        get_property(license_notices_dir GLOBAL PROPERTY license_notices_SOURCE_DIR)
        muse_install_license_notice(zlib "${license_notices_dir}/zlib-1.2.8" "README")
        muse_install_license_notice(libsndfile "${license_notices_dir}/libsndfile-1.0.25" "COPYING")
        muse_install_license_notice(openssl "${license_notices_dir}/openssl-1.1.1c" "LICENSE")

        # GNU FreeFont is embedded through qrc; the shipped FreeSans/FreeSerif files are
        # byte-identical to the 20120503 release, whose COPYING is GPL-3.0 and whose README
        # carries the font exception.
        muse_install_license_notice(freefont "${license_notices_dir}/freefont-20120503"
            "COPYING" "README" "AUTHORS")

        # Per-module Qt notices and attribution from the pinned source archives of the modules
        # the workflow installs (qtbase, qtsvg, qtdeclarative, qttools, qttranslations plus the
        # qt5compat / qtnetworkauth / qtshadertools / qtwebsockets addons).
        muse_install_qt_module_notices("${license_notices_dir}"
            qtbase qtdeclarative qtsvg qttools qttranslations
            qt5compat qtnetworkauth qtshadertools qtwebsockets)
    endif()
endif(OS_IS_WIN)
