local recipes = require("noneed.tech_to_recipe")
local set = require("libs.modss.Set")
local lookup = require("libs.common.lookup")
local util = require("libs.factorio.util")

local add_ingredients,
add_results
-- ,build_item_list

---comment
---@param collector table
---@param recipe table
---@param tier integer
function add_results(collector, recipe, tier)
    local results = util.get_results(recipe)
    for _, res in ipairs(results) do
        res.tier = tier
        collector:add(res.name, res)
    end
end

---comment
---@param collector table
---@param recipe table
---@param tier integer
function add_ingredients(collector, recipe, tier)
    local ingredient = util.get_ingredients(recipe)
    for _, ing in ipairs(ingredient) do
        ing.amount = 1
        ing.tier = tier
        if not collector:add(ing.name, ing) then
            local current_tier = collector.values[ing.name].tier
            if tier < current_tier then
                collector.values[ing.name].tier = tier
            end
        end
    end
end

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
---
