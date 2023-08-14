local Set = require("data_structs.Set")

local function build_graph()
    local add_resever_edges,
    add_reverse_edge,
    get_start_node

    function add_resever_edges()
        for _, tech in pairs(data.raw.technology) do
            if tech.prerequisites ~= nil then
                add_reverse_edge(tech.prerequisites, tech.name)
            end
        end
    end

    function add_reverse_edge(prerequisites, name)
        for _, prerequisite in pairs(prerequisites) do
            local tech = data.raw.technology[prerequisite]
            if tech.postrequisites == nil then
                tech["postrequisites"] = {}
            end
            table.insert(tech.postrequisites, name)
        end
    end

    function get_start_node()
        local start_node = Set.init()
        for key, tech in pairs(data.raw.technology) do
            if key == "automation" then
                print("stop")
            end
            if tech.prerequisites == nil then
                start_node:add(tech.name)
            end
        end
        return start_node
    end

    add_resever_edges()
    return get_start_node()
end

local function init_tier0(tiers, starts)
    local get_t0_packs, get_t0_items, is_enabled, get_ingredients

    function get_t0_packs()
        local packs = Set.init()
        for value, _ in pairs(starts) do
            local pack = data.raw.technology[value].unit.ingredients
            for i, array in ipairs(pack) do
                packs:add(array[1])
            end
        end
        return packs
    end

    function get_t0_items()
        local tier0 = Set.init()
        for _, recipe in pairs(data.raw.recipe) do
            if is_enabled(recipe) then
                tier0:add(recipe.name)
                local ingredients = get_ingredients(recipe)
                for _, ingredient in ipairs(ingredients) do
                    tier0:add(ingredient[1])
                end
            end
        end
        return tier0
    end

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

    function get_ingredients(recipe)
        if recipe == nil then
            return {}
        end
        if recipe.ingredients then
            return recipe.ingredients
        end
        return get_ingredients(recipe.normal)
    end

    local packs = get_t0_packs()
    local items = get_t0_items()

    for pack, _ in pairs(packs) do
        tiers[pack].tier = 0
        tiers[pack].items = items
    end
end


local function build_tiers()
    local get_packs,
    get_recipe

    function get_packs()
        local packs = Set.init()
        for _, key in pairs(data.raw.lab) do
            for _, value in ipairs(key.inputs) do
                packs:add(value)
            end
        end
        return packs
    end

    function get_recipe(packs)
        local recipes = Set.init()
        for value, _ in pairs(packs) do
            if data.raw.recipe[value] ~= nil then
                recipes:add(value)
            end
        end
        return recipes
    end

    local packs = get_packs()
    local recipes = get_recipe(packs)
    local tiers = {}
    packs = Set.intsec(packs, recipes)
    for value, _ in pairs(packs) do
        tiers[value] = { tier = -1, name = value, items = {} }
    end

    return tiers
end

local start_nodes = build_graph()
local tiers = build_tiers()
init_tier0(tiers, start_nodes)

return {
    starts = start_nodes,
    tiers = tiers
}
