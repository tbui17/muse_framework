# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# Failure and validation tests for the pinned dependency payload engine.
#
# Run from the framework root (no build, no network; fixtures are local file:// mirrors):
#
#   cmake -P buildscripts/cmake/deps/tests/run-tests.cmake
#
# Every case runs in its own CMake process, so a dependency-stage FATAL_ERROR is the
# expected outcome for the negative cases. Cases must fail while fetching/validating a
# dependency, with a message naming the dependency, never later.

cmake_minimum_required(VERSION 3.22)

set(_tests_dir "${CMAKE_CURRENT_LIST_DIR}")
set(_case_runner "${_tests_dir}/ops/run-case.cmake")

if (NOT EXISTS "${_case_runner}")
    message(FATAL_ERROR "Test harness error: ${_case_runner} is missing")
endif()

set(_work_root "${_tests_dir}/_work")
file(REMOVE_RECURSE "${_work_root}")
file(MAKE_DIRECTORY "${_work_root}")

# "<case>|<ok|fail>|<expected message substring, or ->"
set(MUSE_DEP_TEST_CASES
    "valid-payload|ok|-"
    "valid-payload-xz|ok|-"
    "valid-recipe|ok|-"
    "cached-payload|ok|-"
    "stale-lock-hash|ok|-"
    "incomplete-destination|ok|-"
    "missing-payload|fail|pinned payload source does not exist"
    "unreachable-payload|fail|could not download pinned payload"
    "hash-mismatch|fail|does not match the pinned"
    "truncated-archive|fail|could not be extracted"
    "unexpected-root|fail|expected exactly one top-level directory"
    "missing-recipe-file|fail|no reviewed recipe at"
    "missing-recipe-function|fail|does not define the expected command"
    "unpinned-recipe|fail|is not pinned in"
    "malformed-payload-entry|fail|malformed payload entry"
)

set(_total 0)
set(_failed 0)

foreach(_entry IN LISTS MUSE_DEP_TEST_CASES)
    string(REPLACE "|" ";" _fields "${_entry}")
    list(GET _fields 0 _case)
    list(GET _fields 1 _expect)
    list(GET _fields 2 _expected_message)
    math(EXPR _total "${_total} + 1")

    set(_case_work "${_work_root}/${_case}")
    file(REMOVE_RECURSE "${_case_work}")

    execute_process(
        COMMAND "${CMAKE_COMMAND}" "-DCASE=${_case}" "-DTEST_WORK_DIR=${_work_root}" -P "${_case_runner}"
        RESULT_VARIABLE _status
        OUTPUT_VARIABLE _output
        ERROR_VARIABLE _error
    )
    set(_combined "${_output}\n${_error}")

    set(_problems "")
    if (_expect STREQUAL "ok")
        if (NOT _status EQUAL 0)
            list(APPEND _problems "expected success, but the case exited with ${_status}")
        endif()
    else()
        if (_status EQUAL 0)
            list(APPEND _problems "expected a dependency-stage failure, but the case exited with 0")
        endif()
    endif()

    if (NOT _expected_message STREQUAL "-")
        string(FIND "${_combined}" "${_expected_message}" _message_index)
        if (_message_index EQUAL -1)
            list(APPEND _problems "the failure message does not contain '${_expected_message}'")
        endif()
    endif()

    # A failed or interrupted fetch must never leave its temporary payload or staging
    # directory behind, and no case may leave an unexplained partial destination.
    file(GLOB _leftover_parts RELATIVE "${_case_work}" "${_case_work}/.pinned/*.part-*")
    file(GLOB _leftover_staging RELATIVE "${_case_work}" "${_case_work}/.staging-*")
    if (_leftover_parts OR _leftover_staging)
        list(APPEND _problems "leftover temporary artifacts: ${_leftover_parts}${_leftover_staging}")
    endif()

    if (_problems)
        math(EXPR _failed "${_failed} + 1")
        message(STATUS "FAIL ${_case}")
        foreach(_problem IN LISTS _problems)
            message(STATUS "     ${_problem}")
        endforeach()
        message(STATUS "---- case output ----")
        message(STATUS "${_combined}")
        message(STATUS "---- end case output ----")
    else()
        message(STATUS "PASS ${_case}")
    endif()
endforeach()

if (_failed GREATER 0)
    message(FATAL_ERROR "${_failed} of ${_total} dependency loader tests failed")
endif()

message(STATUS "All ${_total} dependency loader tests passed")
