# zlib is provided by the pinned prebuilt Windows dependencies
# (framework/cmake/MuseFetchDependencies.cmake). Fail here with the expected location
# instead of surfacing an unresolved import at link time.
if (NOT EXISTS "${DEPENDENCIES_LIB_DIR}/zlibstat.lib")
    message(FATAL_ERROR
        "[zlib] ${DEPENDENCIES_LIB_DIR}/zlibstat.lib was not found. "
        "The pinned Windows prebuilt dependencies are missing or DEPENDENCIES_LIB_DIR is not set.")
endif()
if (NOT EXISTS "${DEPENDENCIES_INC}/zlib/zlib.h")
    message(FATAL_ERROR
        "[zlib] ${DEPENDENCIES_INC}/zlib/zlib.h was not found. "
        "The pinned Windows prebuilt dependencies are missing or DEPENDENCIES_INC is not set.")
endif()

if (NOT TARGET zlib::zlib)
    add_library(zlib::zlib STATIC IMPORTED GLOBAL)
    set_target_properties(zlib::zlib PROPERTIES
        IMPORTED_LOCATION "${DEPENDENCIES_LIB_DIR}/zlibstat.lib"
        INTERFACE_INCLUDE_DIRECTORIES "${DEPENDENCIES_INC}/zlib")
endif()

# Keep CMake's FindZLIB module pointed at the same pinned headers and library
# when vendored consumers ask for its uppercase target.
set(ZLIB_INCLUDE_DIR "${DEPENDENCIES_INC}/zlib" CACHE PATH
    "Pinned zlib include directory" FORCE)
set(ZLIB_LIBRARY "${DEPENDENCIES_LIB_DIR}/zlibstat.lib" CACHE FILEPATH
    "Pinned zlib library" FORCE)
