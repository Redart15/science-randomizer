
local recipes = require("prototype.prep.build_recipe")
print("hi")

for key, value in pairs(recipes) do
    local recipe = data.raw.recipe[key]
    recipe.ingredients = value.ingredients
    recipe.category = value.category
end
print("hi")
