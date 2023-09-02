local recipes = require("prep.tier_to_prototypes")
local set = require("libs.data_structs.Set")
local dataRecipe = data.raw.recipe
local calc_cost, calc_crafting_category

function calc_cost(ingredients)
    local sum = 0
    for _, item in pairs(ingredients) do
        sum = sum + item.amount * item.cost
    end
    return sum
end

function calc_crafting_category(fluidCount)
    if fluidCount == 0 then
        return "crafting"
    end
    if fluidCount == 1 then
        return "crafting-with-fluid"
    end
    return "chemistry"
end

for _, recipe in ipairs(recipes.item_list) do
    local pack = dataRecipe[recipe.name]
    pack.ingredients = recipe.recipe:to_list()
    pack.category = calc_crafting_category(recipe.fluidCount)
    if recipes.settings.isBalanced == true then
        local cost = calc_cost(recipe.recipe.values)
        pack.result_count = math.ceil(cost / recipe.cost)
    end
end
