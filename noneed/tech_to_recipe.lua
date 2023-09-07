local Set = require("libs.mods.set")
local Lookup = require("libs.common.lookup")

-- function deklaration
local add_tiered_recipe,
unlocks_effects,
filter_recipe,
get_tier,
research_packs,
is_enabled

---comment
---@param collector table
---@param tech any
function add_tiered_recipe(collector, tech)
    local ingredients = research_packs(tech.unit.ingredients)
    local effects = unlocks_effects(tech).normal
    effects = filter_recipe(effects)
    if effects ~= nil then
        for _, effect in ipairs(effects) do
            local tier = get_tier(tech.name, ingredients)
            -- if Lookup.max_tier >= tier then
                collector:add(effect, tier)
            -- end
        end
    end
end

---comment
---@param tech table
---@return table
function unlocks_effects(tech)
    if tech == nil then
        return {}
    end
    if tech.effects then
        return {
            normal = tech.effects
        }
    end
    return {
        normal = unlocks_effects(tech.normal),
        expensive = unlocks_effects(tech.expensive),
    }
end

---comment
---@param effects table
---@return table
function filter_recipe(effects)
    if effects == nil then
        return {}
    end
    local temp = {}
    for _, value in ipairs(effects) do
        if value.type == "unlock-recipe" then
            table.insert(temp, value.recipe)
        end
    end
    return temp
end

---comment
---@param techname string
---@param ingredients table
---@return integer
function get_tier(techname, ingredients)
    if techname == "logistic-science-pack" then
        print("hi")
    end
    local tier = 1
    local packs = Set.from_list(ingredients)
    packs:add(techname,0)
    for key in packs:iterate() do
        local temp = Lookup.science[key]
        if temp ~=nil then
            if temp > tier then
                tier = temp
            end
        end
    end
    return tier + 1
end

---comment
---@param ingredients any
---@return table
function research_packs(ingredients)
    local temp = {}
    if ingredients == nil then
        return temp
    end
    for _, value in pairs(ingredients) do
        if value.name == nil then
            table.insert(temp, value[1])
        else
            table.insert(temp, value.name)
        end
    end
    return temp
end

---comment
---@param recipe table
---@return boolean
function is_enabled(recipe)
    if not recipe then
        return false
    end
    if recipe.normal then
        return is_enabled(recipe.normal)
    end
    if recipe.expensive then
        return is_enabled(recipe.expensive)
    end
    return recipe.enabled == true or recipe.enabled == nil
end

---
local recipes = Set.init()
for _, tech in pairs(data.raw.technology) do
    add_tiered_recipe(recipes, tech)
end

for _, recipe in pairs(data.raw.recipe) do
    if is_enabled(recipe) then
        local tier = 1
        if Lookup:isScience(recipe.name) then
            tier = 2
        end
        recipes:add(recipe.name, tier)
    end
end
return recipes
---
