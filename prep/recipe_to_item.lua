local recipes = require("prep.tech_to_recipe")
local set = require("libs.data_structs.Set")
local lookup = require("prep.lookup")

local get_results,
get_type,
fix_up,
get_ingredients,
add_ingredients,
add_results,
get_count,
calc_cost,
build_item_list

---comment
---@param recipe table
---@return table
function get_results(recipe)
    if recipe.results then
        return fix_up(recipe.results)
    end
    if recipe.normal then
        return get_results(recipe.normal)
    end
    return fix_up({ recipe.result })
end

---comment
---@param results table
---@return table
function fix_up(results)
    local temp = {}
    for _, result in ipairs(results) do
        local item
        if result[2] ~= nil and item == nil then
            item = {
                name = result[1],
                amount = result[2]
            }
        end
        if result.name == nil and item == nil then
            item = {
                name = result,
                amount = 1
            }
        end
        if result.name ~= nil and item == nil then
            item = {
                name = result.name,
                amount = result.amount
            }
        end
        table.insert(temp, item)
    end
    return temp
end

---comment
---@param recipe table
---@return table
function get_ingredients(recipe)
    if recipe == nil then
        return {}
    end
    if recipe.normal ~= nil then
        return get_ingredients(recipe.normal)
    end
    if recipe.ingredients ~= nil then
        return fix_up(recipe.ingredients)
    end
    return {}
end

---comment
---@param collector table
---@param recipe table
---@param tier integer
function add_results(collector, recipe, tier)
    local results = get_results(recipe)
    for _, res in ipairs(results) do
        res.tier = tier
        -- res.type = get_type(res.name)
        res.cost = lookup:isBase(res.name) and lookup.base[res.name] or 0
        collector:add(res.name, res)
    end
end

---comment
---@param collector table
---@param recipe table
---@param tier integer
function add_ingredients(collector, recipe, tier)
    local ingredient = get_ingredients(recipe)
    for _, ing in ipairs(ingredient) do
        ing.amount = 1
        ing.tier = tier
        -- ing.type = get_type(ing.name)
        ing.cost = lookup:isBase(ing.name) and lookup.base[ing.name] or 0
        if not collector:add(ing.name, ing) then
            local current_tier = collector.values[ing.name].tier
            if tier < current_tier then
                collector.values[ing.name].tier = tier
            end
        end
    end
end

---comment
---@param recipe table
---@return integer
function get_count(recipe)
    local count
    if recipe.results ~= nil and next(recipe.results) ~= nil then
        count = 0
        local results = get_results(recipe)
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

---comment
---@param itemname any
---@return integer
function calc_cost(itemname)
    local recipe = data.raw.recipe[itemname]
    local ingredients = get_ingredients(recipe)
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
---@return table
function build_item_list()
    local item_set = set.init()
    for key, tier in pairs(recipes.values) do
        local recipe = data.raw.recipe[key]
        add_results(item_set, recipe, tier)
        add_ingredients(item_set, recipe, tier)
    end
    local item_list = item_set:to_list()
    table.sort(
        item_list,
        function(a, b)
            return a.tier < b.tier
        end
    )
    return item_list
end

---
local item_list = build_item_list()
for _, item in ipairs(item_list) do
    item.amount = nil
    if item.cost == 0 then
        local new_cost = lookup["costs"][item.name]
        if new_cost == nil then
            item.cost = calc_cost(item.name)
        else
            item.cost = new_cost
        end
    end
end

return item_list
---
