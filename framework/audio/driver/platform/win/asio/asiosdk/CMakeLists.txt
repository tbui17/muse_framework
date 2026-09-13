
muse_create_thirdparty_module(asiosdk)

if(MUSE_MODULE_AUDIO_ASIO_SDK_PATH)
    set(ASIO_SDK_PATH ${MUSE_MODULE_AUDIO_ASIO_SDK_PATH})
else()

    # If not set MUSE_MODULE_AUDIO_ASIO_SDK_PATH use the pinned ASIO SDK.
    # The reviewed recipe is buildscripts/cmake/deps/asiosdk.cmake; its payload URL and
    # SHA-256 are pinned in buildscripts/cmake/deps/dependencies.lock.cmake.
    include(DependencyPayload)

    muse_dependency_output_dir(asiosdk _asio_output_dir)
    muse_dependency_populate(asiosdk "${_asio_output_dir}")

    set(ASIO_SDK_PATH "${_asio_output_dir}")
    message(STATUS "ASIO_SDK_PATH: ${ASIO_SDK_PATH}")

endif()

target_sources(asiosdk PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/asiosdk_asio.cpp
    ${CMAKE_CURRENT_LIST_DIR}/asiosdk_asiolist.cpp
    ${CMAKE_CURRENT_LIST_DIR}/asiosdk_asiodrivers.cpp
)

target_include_directories(asiosdk PUBLIC
    ${ASIO_SDK_PATH}
    ${ASIO_SDK_PATH}/ASIOSDK/common
    ${ASIO_SDK_PATH}/ASIOSDK/host
    ${ASIO_SDK_PATH}/ASIOSDK/host/pc
)

# Silence warnings from SDK
target_compile_options(asiosdk PRIVATE /wd4267)
