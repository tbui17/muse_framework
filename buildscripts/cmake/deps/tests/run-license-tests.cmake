# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Configure/install fixtures for the Qt notice installer. Run from the framework root:
#
#   cmake -P buildscripts/cmake/deps/tests/run-license-tests.cmake
#
# The positive fixture models SPIRV-Cross metadata that names only COPYRIGHT.txt. The
# required LICENSE is not attribution metadata, so the fixture catches validation-only
# required entries by asserting that the required file still reaches the install tree.

cmake_minimum_required(VERSION 3.22)

set(_tests_dir "${CMAKE_CURRENT_LIST_DIR}")
set(_module "${_tests_dir}/../../SetupLicenseNotices.cmake")
set(_fixture "${_tests_dir}/fixtures/qtshadertools-everywhere-src-6.10.2")
set(_work "${_tests_dir}/_work-notices")

if (NOT EXISTS "${_module}")
    message(FATAL_ERROR "Test harness error: notice installer not found at ${_module}")
endif()
if (NOT IS_DIRECTORY "${_fixture}")
    message(FATAL_ERROR "Test harness error: Qt notice fixture not found at ${_fixture}")
endif()

file(REMOVE_RECURSE "${_work}")
file(MAKE_DIRECTORY "${_work}")

function(_write_fixture_project source_dir payload_dir)
    file(MAKE_DIRECTORY "${source_dir}")
    file(WRITE "${source_dir}/CMakeLists.txt"
        "cmake_minimum_required(VERSION 3.22)\n"
        "project(qt_notice_fixture NONE)\n"
        "set(MUSE_APP_INSTALL_RESOURCES_LOCATION \".\")\n"
        "include(\"${_module}\")\n"
        "muse_install_qt_module_notices(\"${payload_dir}\" qtshadertools)\n")
endfunction()

# A required notice must be installed even when the attribution metadata only names a
# different legal file from the same source directory.
set(_valid_case "${_work}/required-license-installed")
set(_valid_payload "${_valid_case}/payload")
set(_valid_source "${_valid_case}/source")
set(_valid_build "${_valid_case}/build")
set(_valid_prefix "${_valid_case}/install")
file(COPY "${_fixture}" DESTINATION "${_valid_payload}")
_write_fixture_project("${_valid_source}" "${_valid_payload}")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -S "${_valid_source}" -B "${_valid_build}"
        "-DCMAKE_INSTALL_PREFIX=${_valid_prefix}"
    RESULT_VARIABLE _valid_configure_status
    OUTPUT_VARIABLE _valid_configure_output
    ERROR_VARIABLE _valid_configure_error)
if (NOT _valid_configure_status EQUAL 0)
    message(FATAL_ERROR
        "Required-license fixture failed to configure (status ${_valid_configure_status}):\n"
        "${_valid_configure_output}\n${_valid_configure_error}")
endif()
execute_process(
    COMMAND "${CMAKE_COMMAND}" --install "${_valid_build}"
    RESULT_VARIABLE _valid_install_status
    OUTPUT_VARIABLE _valid_install_output
    ERROR_VARIABLE _valid_install_error)
if (NOT _valid_install_status EQUAL 0)
    message(FATAL_ERROR
        "Required-license fixture failed to install (status ${_valid_install_status}):\n"
        "${_valid_install_output}\n${_valid_install_error}")
endif()
set(_required_license
    "${_valid_prefix}/licenses/qt-libraries/qtshadertools/src/3rdparty/SPIRV-Cross/LICENSE")
if (NOT EXISTS "${_required_license}")
    message(FATAL_ERROR
        "Required-license fixture did not install the required SPIRV-Cross LICENSE at "
        "${_required_license}")
endif()
set(_attribution_copyright
    "${_valid_prefix}/licenses/qt-libraries/qtshadertools/src/3rdparty/SPIRV-Cross/COPYRIGHT.txt")
if (NOT EXISTS "${_attribution_copyright}")
    message(FATAL_ERROR
        "Required-license fixture did not install the attribution COPYRIGHT.txt at "
        "${_attribution_copyright}")
endif()
message(STATUS "PASS required SPIRV-Cross LICENSE installs beside copyright-only attribution")

# Removing a required source file must remain a configure-time failure.
set(_missing_case "${_work}/missing-required-license")
set(_missing_payload "${_missing_case}/payload")
set(_missing_source "${_missing_case}/source")
set(_missing_build "${_missing_case}/build")
set(_missing_prefix "${_missing_case}/install")
file(COPY "${_fixture}" DESTINATION "${_missing_payload}")
file(REMOVE
    "${_missing_payload}/qtshadertools-everywhere-src-6.10.2/src/3rdparty/SPIRV-Cross/LICENSE")
_write_fixture_project("${_missing_source}" "${_missing_payload}")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -S "${_missing_source}" -B "${_missing_build}"
        "-DCMAKE_INSTALL_PREFIX=${_missing_prefix}"
    RESULT_VARIABLE _missing_configure_status
    OUTPUT_VARIABLE _missing_configure_output
    ERROR_VARIABLE _missing_configure_error)
if (_missing_configure_status EQUAL 0)
    message(FATAL_ERROR "Missing-required-license fixture unexpectedly configured successfully")
endif()
set(_missing_output "${_missing_configure_output}\n${_missing_configure_error}")
string(FIND "${_missing_output}" "required notice" _missing_notice_index)
string(FIND "${_missing_output}" "SPIRV" _missing_module_index)
string(FIND "${_missing_output}" "LICENSE" _missing_file_index)
string(FIND "${_missing_output}" "missing from the pinned" _missing_marker_index)
if (_missing_notice_index EQUAL -1
    OR _missing_module_index EQUAL -1
    OR _missing_file_index EQUAL -1
    OR _missing_marker_index EQUAL -1)
    message(FATAL_ERROR
        "Missing-required-license fixture failed without the required notice diagnostic:\n"
        "${_missing_output}")
endif()
message(STATUS "PASS missing required SPIRV-Cross LICENSE fails during configure")

# The current MuseDeps ownership is an extracted source payload, not
# framework/global/thirdparty/utfcpp. Keep the target include root, installed notice,
# and source index path tied to that one reviewed layout.
set(_utfcpp_case "${_work}/utfcpp-source-ownership")
set(_utfcpp_payload "${_utfcpp_case}/payload")
set(_utfcpp_source "${_utfcpp_case}/source")
set(_utfcpp_build "${_utfcpp_case}/build")
set(_utfcpp_prefix "${_utfcpp_case}/install")
file(MAKE_DIRECTORY "${_utfcpp_payload}/utfcpp/source" "${_utfcpp_source}")
file(WRITE "${_utfcpp_payload}/utfcpp/LICENSE" "utf8cpp test license\n")
file(WRITE "${_utfcpp_payload}/utfcpp/source/utf8.h" "#pragma once\n")
file(WRITE "${_utfcpp_source}/CMakeLists.txt"
    "cmake_minimum_required(VERSION 3.22)\n"
    "project(utfcpp_source_ownership NONE)\n"
    "set(MUSE_APP_INSTALL_RESOURCES_LOCATION \"${_utfcpp_prefix}\")\n"
    "include(\"${_module}\")\n"
    "add_library(utfcpp INTERFACE IMPORTED GLOBAL)\n"
    "set_target_properties(utfcpp PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "
    "\"${_utfcpp_payload}/utfcpp/source\")\n"
    "get_target_property(_include_root utfcpp INTERFACE_INCLUDE_DIRECTORIES)\n"
    "if (NOT _include_root STREQUAL \"${_utfcpp_payload}/utfcpp/source\")\n"
    "    message(FATAL_ERROR \"utf8cpp target does not use its fetched source root\")\n"
    "endif()\n"
    "muse_install_license_notice(utf8cpp \"${_utfcpp_payload}/utfcpp\" \"LICENSE\")\n"
    "muse_install_source_index(\"utfcpp/source|utf8cpp 4.1.1, pinned source payload\")\n")
execute_process(
    COMMAND "${CMAKE_COMMAND}" -S "${_utfcpp_source}" -B "${_utfcpp_build}"
        "-DCMAKE_INSTALL_PREFIX=${_utfcpp_prefix}"
    RESULT_VARIABLE _utfcpp_configure_status
    OUTPUT_VARIABLE _utfcpp_configure_output
    ERROR_VARIABLE _utfcpp_configure_error)
if (NOT _utfcpp_configure_status EQUAL 0)
    message(FATAL_ERROR
        "utf8cpp source ownership fixture failed to configure:\n"
        "${_utfcpp_configure_output}\n${_utfcpp_configure_error}")
endif()
execute_process(
    COMMAND "${CMAKE_COMMAND}" --install "${_utfcpp_build}"
    RESULT_VARIABLE _utfcpp_install_status
    OUTPUT_VARIABLE _utfcpp_install_output
    ERROR_VARIABLE _utfcpp_install_error)
if (NOT _utfcpp_install_status EQUAL 0)
    message(FATAL_ERROR
        "utf8cpp source ownership fixture failed to install:\n"
        "${_utfcpp_install_output}\n${_utfcpp_install_error}")
endif()
if (NOT EXISTS "${_utfcpp_prefix}/licenses/utf8cpp/LICENSE")
    message(FATAL_ERROR
        "utf8cpp source ownership fixture did not install the fetched payload license")
endif()
file(READ "${_utfcpp_prefix}/licenses/SOURCE-REFS.txt" _utfcpp_source_refs)
string(FIND "${_utfcpp_source_refs}" "utfcpp/source  utf8cpp 4.1.1, pinned source payload" _utfcpp_source_index)
string(FIND "${_utfcpp_source_refs}" "framework/global/thirdparty/utfcpp" _utfcpp_stale_index)
if (_utfcpp_source_index EQUAL -1 OR NOT _utfcpp_stale_index EQUAL -1)
    message(FATAL_ERROR
        "utf8cpp source ownership fixture emitted an incorrect source index:\n"
        "${_utfcpp_source_refs}")
endif()
message(STATUS "PASS utf8cpp target, installed notice, and source index use fetched payload")

message(STATUS "All 3 Qt notice fixture tests passed")
