local util = require("libs.factorio.util")
local recipes = require("prep.tier_to_prototypes")
local lookup = require("prep.lookup")
local dataRecipe = data.raw.recipe
local calc_costs,
calc_crafting_category,
build_results,
calc_cost,
get_count

---comment
---@param itemname any
---@return integer
function calc_cost(itemname)
    local recipe = data.raw.recipe[itemname]
    local ingredients = util.get_ingredients(recipe)
    if next(ingredients) == nil then
        return 3
    end
    local sum = 0
    for _, ing in ipairs(ingredients) do
        local cost = lookup["costs"][ing.name]
        if cost == nil or cost == 0 then
            cost = calc_cost(ing.name)
        end
        sum = sum + cost * ing.amount
    end
    local count = get_count(recipe)
    local cost = math.ceil(sum / count)
    lookup["costs"][itemname] = cost
    return cost
end

---comment
---@param recipe table
---@return integer
function get_count(recipe)
    local count
    if recipe.results ~= nil and next(recipe.results) ~= nil then
        count = 0
        local results = util.get_results(recipe)
        for _, result in ipairs(results) do
            count = count + result.amount
        end
        return count
    end
    if recipe.result_count ~= nil then
        return recipe.result_count
    end
    return 1
end

function calc_costs(ingredients)
    local sum = 0
    for _, item in pairs(ingredients) do
        sum = sum + item.amount * calc_cost(item.name)
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
    local packCost = calc_cost(recipe.name)
    pack.ingredients = recipe.ingredients
    pack.category = calc_crafting_category(recipe.fluidCount)
    local count
    if recipes.settings.isBalanced == true then
        local cost = calc_costs(recipe.ingredients)
        count = math.ceil(cost / packCost)
    end
    pack.results = build_results(pack, recipe, count)
end

print(data.raw.recipe["automation-science-pack"])