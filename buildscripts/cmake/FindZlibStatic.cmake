# zlib is provided by the pinned prebuilt Windows dependencies
# (framework/cmake/MuseFetchDependencies.cmake). Fail here with the expected location
# instead of surfacing an unresolved import at link time.
if (NOT EXISTS "${DEPENDENCIES_LIB_DIR}/zlibstat.lib")
    message(FATAL_ERROR
        "[zlibstat] ${DEPENDENCIES_LIB_DIR}/zlibstat.lib was not found. "
        "The pinned Windows prebuilt dependencies are missing or DEPENDENCIES_LIB_DIR is not set.")
endif()

add_library(zlibstat STATIC IMPORTED)
set_target_properties(zlibstat PROPERTIES IMPORTED_LOCATION ${DEPENDENCIES_LIB_DIR}/zlibstat.lib)
