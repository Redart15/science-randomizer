local Set = require("data_structs.Set")

local function build_tiers(science_packs)
    local build_tier0, fill_tiers

    function build_tier0()
        local get_t0_items, is_enabled, get_ingredients

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

        return get_t0_items()
    end


    function fill_tiers(tiers)
        local get_items, get_tier, get_packs, get_current_tier

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
            for index, value in ipairs(science_packs) do
                if value == seach_key then
                    return index
                end
            end
            return -1
        end

        function get_tier(ingredients)
            local tier = -1
            local packs = get_packs(ingredients)
            for key, _ in pairs(packs) do
                local current_tier = get_current_tier(key)
                if current_tier > tier then
                    tier = current_tier
                end
            end
            return tier
        end

        local techs = data.raw.technology

        for _, tech in pairs(techs) do
            local items = get_items(tech.effects)
            local tier = get_tier(tech.unit.ingredients)

            for _, item in ipairs(items) do
                tiers[tier+1].items:add(item)
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
    tiers[last_tier + 1] = {name = "last_tier", items = Set.init()}
    fill_tiers(tiers)
    tiers[1].items = build_tier0()

    return tiers
end

return build_tiers
