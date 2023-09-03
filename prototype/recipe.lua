local recipes = require("prep.tier_to_prototypes")
local dataRecipe = data.raw.recipe
local calc_cost, calc_crafting_category, build_results

function calc_cost(ingredients)
    local sum = 0
    for _, item in pairs(ingredients) do
        sum = sum + item.amount * item.cost
    end
    return sum
end

function build_results(pack, recipe, count)
    local temp = {}
    local result = {
        name = recipe.name,
        amount = count,
        type = "item"
    }
    table.insert(temp, result)
    return temp
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
    local count
    if recipes.settings.isBalanced == true then
        local cost = calc_cost(recipe.recipe.values)
        count = math.ceil(cost / recipe.cost)
    end
    pack.results = build_results(pack, recipe, count)
    print("hi")
end

print(data.raw.recipe["automation-science-pack"])