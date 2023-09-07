require("libs.random.randomlua")
local set = require("libs.common.set")
local lookup = require("libs.common.lookup")
local util = require("libs.common.util")
local cost_table = {}

-- constant
local fluidMuliplier = 20

local function calc_prototype(config)
    -- function deklaration
    -- techs2Recipes
    local add_tiered_recipe,
    unlocks_effects,
    filter_recipe,
    get_tier,
    research_packs,
    is_enabled

    -- recipes2Items
    local add_ingredients,
    add_results

    -- items2Tiers
    -- none

    -- tiers2Prototypes
    local generate_prototype,
    populate,
    get_type_table,
    add_item,
    initRecipe,
    calc_crafting_category,
    calc_costs,
    calc_cost,
    build_results,
    get_count,
    calc_result_count,
    set_cost


    ---comment
    ---@param collector table
    ---@param tech any
    function add_tiered_recipe(collector, tech)
        local ingredients = research_packs(tech.unit.ingredients)
        local effects = unlocks_effects(tech)
        effects = filter_recipe(effects)
        if effects ~= nil then
            for _, effect in ipairs(effects) do
                local tier = get_tier(tech.name, ingredients)
                if lookup.max_tier >= tier then
                    collector:add(effect, tier)
                end
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
            return tech.effects
        end
        return unlocks_effects(tech.normal)
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
        local packs = set.from_list(ingredients)
        packs:add(techname, 0)
        for key in packs:iterate() do
            local temp = lookup.science[key]
            if temp ~= nil then
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

    ---comment
    ---@param config table
    ---@return table
    function populate(config)
        local temp = { "item", }
        if config.allowFluid then
            table.insert(temp, "fluid")
        end
        if config.allowRaw then
            table.insert(temp, "raw")
        end
        if config.allowScience then
            table.insert(temp, "science")
        end
        if config.allowGrown then
            table.insert(temp, "grown")
        end
        return temp
    end

    function get_type_table(type_table, item_lists, fluidCount)
        local temp = {}
        for index, ttype in ipairs(type_table) do
            if next(item_lists[ttype]) ~= nil then
                if ttype == "fluid" and fluidCount < 1 then
                    table.insert(temp, ttype)
                else
                    table.insert(temp, ttype)
                end
            end
        end
        return temp
    end

    function add_item(current_pack, item_list, type_table, generate)
        local table_index = generate:random(1, #type_table)
        for k = 1, #type_table do
            local ttype = type_table[table_index]
            if (ttype == "fluid" and current_pack.fluidCount < 2) or ttype ~= "fluid" then
                local item_index = generate:random(1, #item_list[ttype])
                for i = 1, #item_list[ttype] do
                    local item = item_list[ttype][item_index]
                    if current_pack.ingredients:add(item.name, item) then
                        item.amount = generate:random(1, 10)
                        item.type = "item"
                        if ttype == "fluid" then
                            current_pack.fluidCount = current_pack.fluidCount + 1
                            item.type = "fluid"
                            item.amount = item.amount * fluidMuliplier
                        end
                        return true
                    else
                        item_index = (item_index % #item_list[ttype]) + 1
                    end
                end
            end
            table_index = (table_index % #type_table) + 1
        end
        return false
    end

    function initRecipe(name)
        local recipe = {}
        recipe.name = name
        recipe.fluidCount = 0
        recipe.ingredients = set.init()
        return recipe
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

    function calc_costs(ingredients)
        local sum = 0
        for _, item in pairs(ingredients) do
            sum = sum + item.amount * calc_cost(item.name)
        end
        return sum
    end

    function calc_cost(itemname)
        local recipe = data.raw.recipe[itemname]
        local ingredients = util.get_ingredients(recipe)
        if next(ingredients) == nil then
            return 3
        end
        local sum = 0
        for _, ing in ipairs(ingredients) do
            local cost = set_cost(ing.name)
            sum = sum + cost * ing.amount
        end
        local count = get_count(recipe)
        local cost = math.ceil(sum / count)
        cost_table[itemname] = cost
        return cost
    end

    function set_cost(name)
        local local_cost = lookup["base"][name]
        local lookup_table_base = cost_table[name]
        if local_cost ~= nil then
            return local_cost
        end
        if lookup_table_base ~= nil then
            return lookup_table_base
        end
        return calc_cost(name)
    end

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

    function calc_result_count(name, ingredients, balance)
        if balance == true then
            local cost = calc_cost(name)
            local ingredient_cost = calc_costs(ingredients)
            return math.ceil(ingredient_cost / cost)
        end
        return 1
    end

    function build_results(prototype, balance)
        local result_count = calc_result_count(prototype.name, prototype.ingredients, balance)
        local result = {
            name = prototype.name,
            amount = result_count,
            type = "item"
        }
        return { result }
    end

    function generate_prototype(tier_list, config, generate)
        local recipes = {}
        local config_type_table = populate(config)
        for tier = 1, #tier_list do
            local recipe = initRecipe(tier_list[tier].name)
            local max_tier = tier
            local min_tier = config.inTier and tier or 1
            local ingredientCount = generate:random(1, 5)
            while recipe.ingredients.size < ingredientCount do
                local current_tier = generate:random(min_tier, max_tier)
                local item_lists = tier_list[current_tier].items
                local type_table = get_type_table(config_type_table, item_lists, recipe.fluidCount)
                if not add_item(recipe, item_lists, type_table, generate) then
                    ingredientCount = (ingredientCount >= 0) and (ingredientCount - 1) or 0
                end
            end
            recipe.category = calc_crafting_category(recipe.fluidCount)
            recipe.fluidCount = nil
            recipe.ingredients = recipe.ingredients:to_list()
            recipe.results = build_results(recipe, config.isBalanced)
            table.insert(recipes, recipe)
        end
        return recipes
    end

    -- ========================================================================
    if config.setRecipe ~= "" then
        return
    end

    local recipes = set.init()
    for _, tech in pairs(data.raw.technology) do
        add_tiered_recipe(recipes, tech)
    end

    for _, recipe in pairs(data.raw.recipe) do
        if is_enabled(recipe) then
            local tier = 1
            if lookup:isScience(recipe.name) then
                tier = 2
            end
            recipes:add(recipe.name, tier)
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

    local tiered_item_list = {}

    for i = 1, lookup.max_tier do
        local name = lookup:tier_name(i)
        tiered_item_list[i] = {
            name = name,
            items = {
                ["science"] = {},
                ["raw"] = {},
                ["grown"] = {},
                ["fluid"] = {},
                ["item"] = {}
            }
        }
    end

    for _, value in ipairs(item_list) do
        local tier = value.tier
        value.tier = nil
        if tier <= lookup.max_tier then
            local type = lookup:get_type(value.name)
            table.insert(tiered_item_list[tier].items[type], value)
        end
    end

    for _, tier in pairs(tiered_item_list) do
        for _, lists in pairs(tier.items) do
            table.sort(
                lists,
                function(this, that)
                    return this.name < that.name
                end
            )
        end
    end

    local gen = mwc(config.seed)
    local prototypes = generate_prototype(tiered_item_list, config, gen)
    return prototypes
    -- ========================================================================
end
return calc_prototype
