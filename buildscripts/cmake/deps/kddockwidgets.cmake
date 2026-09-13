# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Reviewed recipe for KDDockWidgets 2.4. The previous version of this recipe cloned the
# moving "2.4" branch with --depth 1; the reviewed commit is now pinned with its SHA-256
# in dependencies.lock.cmake and extracted to <local_path>/kddockwidgets.

function(kddockwidgets_Populate local_path)
    muse_dependency_payload(kddockwidgets "${local_path}")

    set(src_path "${local_path}/kddockwidgets")

    if (NOT BUILD_SHARED_LIBS)
        set(KDDockWidgets_STATIC ON CACHE BOOL "Build static versions of the libraries" FORCE)
    endif()

    set(KDDockWidgets_QT6 ON CACHE BOOL "Build against Qt 6" FORCE)
    set(KDDockWidgets_FRONTENDS "qtquick" CACHE STRING "Frontends to build" FORCE)
    set(KDDockWidgets_EXAMPLES OFF CACHE BOOL "Build the examples" FORCE)
    set(KDDockWidgets_TESTS OFF CACHE BOOL "Build the tests" FORCE)

    add_subdirectory("${src_path}" "${CMAKE_BINARY_DIR}/kddockwidgets" EXCLUDE_FROM_ALL)

    set_property(GLOBAL PROPERTY kddockwidgets_SOURCE_DIR "${local_path}")
endfunction()
