# Test fixture: looks like a reviewed dependency recipe but deliberately does NOT define
# fixture_recipe_without_function_Populate. muse_dependency_populate() must reject it with
# an explicit message instead of failing later with "Unknown CMake command".

# (no function definitions on purpose)
