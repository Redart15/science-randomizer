require("prototype.science-randomizer.prep.calc-stats")
local recipes = require("prototype.science-randomizer.prep.build_recipe")
print("hi")

for key, value in pairs(recipes) do
    local recipe = data.raw.recipe[key]
    recipe.ingredients = value.ingredients
    recipe.category = value.category
    if recipe.result_count then
        recipe["result_count"] = recipe.result_count * value.result_count_multiplier
    else
        recipe["result_count"] = value.result_count_multiplier
    end
end

print("hi")
