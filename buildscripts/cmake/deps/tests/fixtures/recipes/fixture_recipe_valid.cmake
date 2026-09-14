# Test fixture: a reviewed dependency recipe in the shape the real recipes use, i.e. it
# consumes its pinned payload through muse_dependency_payload() and exposes a source
# directory through a global property.

function(fixture_recipe_valid_Populate local_path)
    muse_dependency_payload(fixture_recipe_valid "${local_path}")

    set_property(GLOBAL PROPERTY fixture_recipe_valid_SOURCE_DIR "${local_path}/fixture-payload")
endfunction()
