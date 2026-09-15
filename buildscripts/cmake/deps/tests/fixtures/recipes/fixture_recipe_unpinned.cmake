# Test fixture: a reviewed dependency recipe whose dependency has no entry in
# dependencies.lock.cmake. It must be rejected rather than fetched from an unpinned source.

function(fixture_recipe_unpinned_Populate local_path)
    muse_dependency_payload(fixture_recipe_unpinned "${local_path}")
endfunction()
