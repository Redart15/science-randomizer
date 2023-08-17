local Set = require("libs.data_structs.Set")

local function build_tiers(science_packs)
    local build_tier1, fill_tiers, transform

    function transform(boxed)
        local lset = Set.init()
        for _, box in ipairs(boxed) do
            for _, value in ipairs(box) do
                lset:add(value)
            end
        end
        return lset
    end

    function build_tier1()
        local get_t1_items, is_enabled, get_ingredients

        function get_t1_items()
            local tier0 = Set.init()
            for _, recipe in pairs(data.raw.recipe) do
                if is_enabled(recipe) then
                    tier0:add(recipe.name)
                end
            end
            local science = transform(science_packs)
            tier0 = Set.diff(tier0, science)
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

        return get_t1_items()
    end

    function fill_tiers(tiers)
        local get_items, get_tier, get_packs, get_current_tier, get_unlocks, check_items

        function get_items(effects)
            if effects == nil then
                return {}
            end
            local items = {}
            for _, value in ipairs(effects) do
                table.insert(items, value.recipe)
            end
            return items
        end

        function get_packs(ingredients)
            local packs = Set.init()
            for _, value in ipairs(ingredients) do
                packs:add(value[1])
            end
            return packs
        end

        function get_current_tier(seach_key)
            for index, dic in ipairs(science_packs) do
                for i, value in ipairs(dic) do
                    if value == seach_key then
                        return index
                    end
                end
            end
            return -1
        end

        function get_unlocks(packs, effects)
            if effects == nil then
                return packs
            end
            local item_set = Set.init()
            for _, unlock in ipairs(effects) do
                item_set:add(unlock.recipe)
            end
            local science = transform(science_packs)
            local additional_pack = Set.intsec(item_set, science)
            local union = Set.union(packs, additional_pack)
            return union
        end

        function get_tier(tech)
            local tier = -1
            local packs = get_packs(tech.unit.ingredients)
            packs = get_unlocks(packs, tech.effects)
            for key, _ in packs:iterate() do
                local current_tier = get_current_tier(key)
                if current_tier > tier then
                    tier = current_tier
                end
            end
            return tier
        end

        function check_items(recipes)
            local recipe_list = data.raw.recipe
            local list        = {}
            for _, recipe in ipairs(recipes) do
                local lookup = recipe_list[recipe]
                -- if lookup == nil then
                -- end
                if lookup.results then
                    for _, item in ipairs(lookup.results) do
                        table.insert(list, item.name)
                    end
                else
                    table.insert(list, lookup.name)
                end
            end
            return list
        end

        local techs = data.raw.technology

        for _, tech in pairs(techs) do
            local items = get_items(tech.effects)
            items = check_items(items)
            local tier = get_tier(tech)

            for _, item in ipairs(items) do
                tiers[tier + 1].items:add(item)
            end
        end
    end

    local tiers = {}
    local last_tier = 0
    for index, value in ipairs(science_packs) do
        tiers[index] = {
            name = value,
            items = Set.init()
        }
        last_tier = index
    end
    -- to catch all the item that would not make it into recipes
    tiers[last_tier + 1] = { name = {"last_tier"}, items = Set.init() }
    fill_tiers(tiers)
    -- that tier wont be needed and thus be discarded
    tiers[last_tier + 1] = nil
    -- tier0 need to queries from recipe, as non of its item are locked by tech
    tiers[1].items = build_tier1()
    -- adds all tier1 packs to tier2
    for _, value in ipairs(science_packs[1]) do
        tiers[2].items:add(value)
    end

    return tiers
end

return build_tiers
