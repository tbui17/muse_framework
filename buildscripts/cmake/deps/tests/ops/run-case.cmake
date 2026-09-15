# SPDX-License-Identifier: GPL-3.0-only
# MuseScore-Studio-CLA-applies
#
# MuseScore Studio
# Music Composition & Notation
#
# Copyright (C) 2026 MuseScore Limited
#
# One dependency-loader test case, selected with -DCASE=<name>. Invoked by run-tests.cmake
# in its own CMake process, so an expected dependency-stage FATAL_ERROR terminates the case
# (the driver asserts both the exit status and the message).

cmake_minimum_required(VERSION 3.22)

if (NOT DEFINED CASE OR CASE STREQUAL "")
    message(FATAL_ERROR "Test harness error: CASE is not set")
endif()
if (NOT DEFINED TEST_WORK_DIR OR TEST_WORK_DIR STREQUAL "")
    message(FATAL_ERROR "Test harness error: TEST_WORK_DIR is not set")
endif()

set(_tests_dir "${CMAKE_CURRENT_LIST_DIR}/..")
set(_fixtures_dir "${_tests_dir}/fixtures")
set(_recipes_dir "${_fixtures_dir}/recipes")
# The engine is buildscripts/cmake/DependencyPayload.cmake, two levels above this
# tests directory (tests/ops/.. -> tests, tests -> deps, deps -> cmake).
set(_engine "${_tests_dir}/../../DependencyPayload.cmake")

if (NOT EXISTS "${_engine}")
    message(FATAL_ERROR "Test harness error: dependency payload engine not found at ${_engine}")
endif()
include("${_engine}")

set(_work "${TEST_WORK_DIR}/${CASE}")
file(REMOVE_RECURSE "${_work}")
file(MAKE_DIRECTORY "${_work}")

# Fixture payloads and their checked-in hashes. The same rule as the real pins applies: the
# hash must match the bytes on disk.
set(_one_root_url "file://${_fixtures_dir}/payload-one-root.tar.gz")
set(_one_root_sha256 "4e19106772dd0aeda1cea5927e26c02e045380f1c506d567805f6d2fa25c0744")
set(_two_roots_url "file://${_fixtures_dir}/payload-two-roots.tar.gz")
set(_two_roots_sha256 "2b500e2108aa16d827d0ad431bbfb399d4a7d9da9c31c7c28d8d31e3d0e58593")
set(_truncated_url "file://${_fixtures_dir}/payload-truncated.tar.gz")
set(_truncated_sha256 "b927179a0b86777c8addfa563ff2c70ec1350e759b4e77401902dd5635231114")
set(_one_root_xz_url "file://${_fixtures_dir}/payload-one-root.tar.xz")
set(_one_root_xz_sha256 "9a67db9dbd4f86819736d0543257cd8cac788f1c9d67b877c80cfaf6d6a409e7")
set(_alternate_url "file://${_fixtures_dir}/payload-alternate-root.tar.gz")
set(_alternate_sha256 "73588e953700a2142f8d3a273b66d1c60d9eb6f688b74960562d2551380ac09e")
set(_missing_mirror_url "file://${_fixtures_dir}/no-such-payload.tar.gz")
set(_wrong_sha256 "0000000000000000000000000000000000000000000000000000000000000000")

function(_assert_exists path)
    if (NOT EXISTS "${path}")
        message(FATAL_ERROR "${CASE}: expected ${path} to exist")
    endif()
endfunction()

function(_assert_no_leftovers work)
    file(GLOB _parts RELATIVE "${work}" "${work}/.pinned/*.part-*")
    file(GLOB _staging RELATIVE "${work}" "${work}/.staging-*")
    if (_parts OR _staging)
        message(FATAL_ERROR "${CASE}: temporary artifacts survived: ${_parts} ${_staging}")
    endif()
endfunction()

if (CASE STREQUAL "valid-payload")
    set(MUSE_DEP_fixture_valid_PAYLOADS "single-root|fixture-payload|${_one_root_url}|${_one_root_sha256}")
    set(MUSE_DEP_fixture_valid_EXPECTED
        "fixture-payload/expected.txt"
        "fixture-payload/sub/marker.txt")

    muse_dependency_payload(fixture_valid "${_work}")

    _assert_exists("${_work}/fixture-payload/expected.txt")
    _assert_exists("${_work}/fixture-payload/sub/marker.txt")
    _assert_exists("${_work}/.pinned/${_one_root_sha256}")
    file(READ "${_work}/fixture-payload/expected.txt" _content)
    string(STRIP "${_content}" _content)
    if (NOT _content STREQUAL "pinned fixture payload")
        message(FATAL_ERROR "${CASE}: unexpected extracted content '${_content}'")
    endif()
    _assert_no_leftovers("${_work}")
    message(STATUS "${CASE}: pinned payload verified, extracted and validated")

elseif (CASE STREQUAL "valid-payload-xz")
    # HarfBuzz is pinned as an upstream .tar.xz release archive, so xz extraction through
    # the CMake tar implementation is part of the supported payload surface.
    set(MUSE_DEP_fixture_valid_xz_PAYLOADS "single-root|fixture-payload|${_one_root_xz_url}|${_one_root_xz_sha256}")
    set(MUSE_DEP_fixture_valid_xz_EXPECTED "fixture-payload/expected.txt")

    muse_dependency_payload(fixture_valid_xz "${_work}")

    _assert_exists("${_work}/fixture-payload/expected.txt")
    _assert_exists("${_work}/.pinned/${_one_root_xz_sha256}")
    _assert_no_leftovers("${_work}")
    message(STATUS "${CASE}: xz payload verified and extracted")

elseif (CASE STREQUAL "valid-recipe")
    set(MUSE_DEP_fixture_recipe_valid_PAYLOADS "single-root|fixture-payload|${_one_root_url}|${_one_root_sha256}")
    set(MUSE_DEP_fixture_recipe_valid_EXPECTED "fixture-payload/expected.txt")

    set(MUSE_DEPS_RECIPE_DIR "${_recipes_dir}")
    muse_dependency_populate(fixture_recipe_valid "${_work}")

    _assert_exists("${_work}/fixture-payload/expected.txt")
    get_property(_source_dir GLOBAL PROPERTY fixture_recipe_valid_SOURCE_DIR)
    if (NOT _source_dir STREQUAL "${_work}/fixture-payload")
        message(FATAL_ERROR "${CASE}: the recipe did not run as expected, SOURCE_DIR is '${_source_dir}'")
    endif()
    _assert_no_leftovers("${_work}")
    message(STATUS "${CASE}: reviewed recipe validated and called")

elseif (CASE STREQUAL "stale-lock-hash")
    # A complete, layout-valid destination must be rebuilt when the reviewed lock pins
    # different bytes for it: completion is bound to the payload hashes, not to paths.
    set(MUSE_DEP_fixture_stale_PAYLOADS "single-root|fixture-payload|${_one_root_url}|${_one_root_sha256}")
    set(MUSE_DEP_fixture_stale_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_stale "${_work}")

    file(READ "${_work}/fixture-payload/expected.txt" _first_content)
    string(STRIP "${_first_content}" _first_content)
    if (NOT _first_content STREQUAL "pinned fixture payload")
        message(FATAL_ERROR "${CASE}: unexpected first payload content '${_first_content}'")
    endif()

    set(MUSE_DEP_fixture_stale_PAYLOADS "single-root|fixture-payload|${_alternate_url}|${_alternate_sha256}")
    muse_dependency_payload(fixture_stale "${_work}")

    _assert_exists("${_work}/fixture-payload/expected.txt")
    file(READ "${_work}/fixture-payload/expected.txt" _second_content)
    string(STRIP "${_second_content}" _second_content)
    if (NOT _second_content STREQUAL "alternate pinned fixture payload")
        message(FATAL_ERROR "${CASE}: the stale destination was reused instead of re-extracted ('${_second_content}')")
    endif()
    _assert_no_leftovers("${_work}")
    message(STATUS "${CASE}: a changed payload hash invalidated the completed destination")

elseif (CASE STREQUAL "cached-payload")
    set(MUSE_DEP_fixture_cached_PAYLOADS "single-root|fixture-payload|${_one_root_url}|${_one_root_sha256}")
    set(MUSE_DEP_fixture_cached_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_cached "${_work}")

    # The validated layout must be reused: a second call with an unavailable payload source
    # proves that nothing is fetched again.
    set(MUSE_DEP_fixture_cached_PAYLOADS "single-root|fixture-payload|${_missing_mirror_url}|${_one_root_sha256}")
    muse_dependency_payload(fixture_cached "${_work}")

    _assert_exists("${_work}/fixture-payload/expected.txt")
    _assert_no_leftovers("${_work}")
    message(STATUS "${CASE}: validated payload reused without refetching")

elseif (CASE STREQUAL "incomplete-destination")
    set(MUSE_DEP_fixture_refetch_PAYLOADS "single-root|fixture-payload|${_one_root_url}|${_one_root_sha256}")
    set(MUSE_DEP_fixture_refetch_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_refetch "${_work}")

    # An incomplete destination must be detected and rebuilt from the verified archive; the
    # unavailable payload source proves the archive is reused rather than downloaded again.
    file(REMOVE "${_work}/fixture-payload/expected.txt")
    set(MUSE_DEP_fixture_refetch_PAYLOADS "single-root|fixture-payload|${_missing_mirror_url}|${_one_root_sha256}")
    muse_dependency_payload(fixture_refetch "${_work}")

    _assert_exists("${_work}/fixture-payload/expected.txt")
    _assert_no_leftovers("${_work}")
    message(STATUS "${CASE}: incomplete destination re-extracted from the verified archive")

elseif (CASE STREQUAL "missing-payload")
    set(MUSE_DEP_fixture_missing_PAYLOADS "single-root|fixture-payload|${_missing_mirror_url}|${_one_root_sha256}")
    set(MUSE_DEP_fixture_missing_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_missing "${_work}")
    message(FATAL_ERROR "${CASE}: a missing payload source was accepted")

elseif (CASE STREQUAL "unreachable-payload")
    # 127.0.0.1:1 is a closed loopback port, so the download fails immediately without
    # leaving the process (or the test suite) dependent on any external service.
    set(MUSE_DEPENDENCY_DOWNLOAD_ATTEMPTS "2")
    set(MUSE_DEP_fixture_unreachable_PAYLOADS "single-root|fixture-payload|http://127.0.0.1:1/payload-one-root.tar.gz|${_one_root_sha256}")
    set(MUSE_DEP_fixture_unreachable_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_unreachable "${_work}")
    message(FATAL_ERROR "${CASE}: an unreachable payload was accepted")

elseif (CASE STREQUAL "hash-mismatch")
    set(MUSE_DEP_fixture_hash_PAYLOADS "single-root|fixture-payload|${_one_root_url}|${_wrong_sha256}")
    set(MUSE_DEP_fixture_hash_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_hash "${_work}")
    message(FATAL_ERROR "${CASE}: a payload with a wrong hash was accepted")

elseif (CASE STREQUAL "truncated-archive")
    # The hash matches the truncated bytes, so the download succeeds and extraction is what
    # must reject the payload.
    set(MUSE_DEP_fixture_truncated_PAYLOADS "single-root|fixture-payload|${_truncated_url}|${_truncated_sha256}")
    set(MUSE_DEP_fixture_truncated_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_truncated "${_work}")
    message(FATAL_ERROR "${CASE}: a truncated archive was accepted")

elseif (CASE STREQUAL "unexpected-root")
    set(MUSE_DEP_fixture_root_PAYLOADS "single-root|fixture-payload|${_two_roots_url}|${_two_roots_sha256}")
    set(MUSE_DEP_fixture_root_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_root "${_work}")
    message(FATAL_ERROR "${CASE}: an archive with two roots was accepted")

elseif (CASE STREQUAL "missing-recipe-file")
    set(MUSE_DEPS_RECIPE_DIR "${_recipes_dir}")
    muse_dependency_populate(absent_fixture_recipe "${_work}")
    message(FATAL_ERROR "${CASE}: a missing recipe was accepted")

elseif (CASE STREQUAL "missing-recipe-function")
    set(MUSE_DEPS_RECIPE_DIR "${_recipes_dir}")
    muse_dependency_populate(fixture_recipe_without_function "${_work}")
    message(FATAL_ERROR "${CASE}: a recipe without the expected command was accepted")

elseif (CASE STREQUAL "unpinned-recipe")
    set(MUSE_DEPS_RECIPE_DIR "${_recipes_dir}")
    muse_dependency_populate(fixture_recipe_unpinned "${_work}")
    message(FATAL_ERROR "${CASE}: an unpinned dependency was accepted")

elseif (CASE STREQUAL "malformed-payload-entry")
    set(MUSE_DEP_fixture_malformed_PAYLOADS "single-root|fixture-payload|${_one_root_url}")
    set(MUSE_DEP_fixture_malformed_EXPECTED "fixture-payload/expected.txt")
    muse_dependency_payload(fixture_malformed "${_work}")
    message(FATAL_ERROR "${CASE}: a malformed lock entry was accepted")

else()
    message(FATAL_ERROR "Test harness error: unknown CASE '${CASE}'")
endif()
