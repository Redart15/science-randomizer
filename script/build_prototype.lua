require("libs.random.randomlua")
local lookup = require("static.randomizer-lookup")
local util = require("static.randomizer-util")

local function calc_prototype(config)
    --[[
        The function calculated the prototypes for eauch of the 6 recipes.
        - queries all recipes unlocked by tech as well as categorises them
        - collect all item used or results from recipes as well as assignign type
        - collectr all item into the tier for each science pack
        - sort eauch of the tier list, to keep them consistent (factorio dict are deterministic, but this is a precausn woth doing)
        - pick out of tier based on settings item and finilizer the prototype
        - returns the functrion
    ]]

    local fluidMuliplier = 20
    local cost_table = {}

    -- forward function declaration
    -- techs2Recipes
    local add_tiered_recipe,
    filter_recipe,
    get_tier,
    research_packs

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
    calc_cost,
    build_results,
    get_count,
    calc_result_count,
    populate_ingredients,
    populate_Item,
    dictToList,
    list2Dict,
    addToDict

    ---@param dict table
    ---@return table
    function dictToList(dict)
        local list = {}
        for _, value in pairs(dict) do
            table.insert(list, value)
        end
        return list
    end

    ---@param list any
    ---@return table
    function list2Dict(list)
        local dict = {}
        for index, value in ipairs(list) do
            dict[value] = index
        end
        return dict
    end

    ---@param dict table
    ---@param key string
    ---@param value any
    ---@return boolean
    function addToDict(dict, key, value)
        if key == nil or value == nil then
            return false
        end
        if not dict[key] then
            dict[key] = value
            return true
        end
        return false
    end

    ---@param accumulator table
    ---@param tech table
    function add_tiered_recipe(accumulator, tech)
        local ingredients = research_packs(tech.unit.ingredients)
        local effects = util.unlocks_effects(tech)
        effects = filter_recipe(effects)
        if effects ~= nil then
            for _, effect in ipairs(effects) do
                local tier = get_tier(tech.name, ingredients)
                addToDict(accumulator, effect, tier)
            end
        end
    end

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

    --- the pack unlock needs to be accounted for as well in order to be categorised correctly
    ---@param techname string
    ---@param ingredients table
    ---@return integer
    function get_tier(techname, ingredients)
        local tier = 1
        local packs = list2Dict(ingredients)
        addToDict(packs, techname, 0)
        for key, _ in pairs(packs) do
            local temp = lookup.science[key]
            if temp ~= nil then
                if temp > tier then
                    tier = temp
                end
            end
        end
        return tier + 1
    end

    --- get the packs used in research
    ---@param ingredients table
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

    --- collects item that are results from recipes
    ---@param accumulator table
    ---@param recipe table
    ---@param tier integer
    function add_results(accumulator, recipe, tier)
        local results = util.get_results(recipe)
        for _, res in ipairs(results) do
            res.tier = tier
            addToDict(accumulator, res.name, res)
        end
    end

    --- some item are never are used as results in recipes and would go otherwise unaccounted
    ---@param collector table
    ---@param recipe table
    ---@param tier integer
    function add_ingredients(collector, recipe, tier)
        local ingredient = util.get_ingredients(recipe)
        for _, ing in ipairs(ingredient) do
            ing.tier = tier
            if not addToDict(collector, ing.name, ing) then
                local current_tier = collector[ing.name].tier
                if tier < current_tier then
                    collector[ing.name].tier = tier
                end
            end
        end
    end

    ---@return table
    function populate()
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

    --- unlike the populate function that denoted what type can be use this return table of what is avaible from the populated table
    ---@param item_lists table
    ---@param fluidCount integer
    ---@return table
    function get_type_table(item_lists, fluidCount)
        local temp = {}
        for _, ttype in ipairs(config.types_table) do
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

    function populate_Item(item, generate, ttype, current_pack)
        item.name = item.name
        item.amount = generate:random(1, 10)
        if ttype == "fluid" then
            current_pack.fluidCount = current_pack.fluidCount + 1
            item.type = "fluid"
            item.amount = item.amount * fluidMuliplier
        else
            item.type = "item"
        end
        return true
    end

    --- return if the action was a succsess, needed for lineare probing of the table
    ---@param current_pack table
    ---@param item_list table
    ---@param type_table table
    ---@param generate table
    ---@return boolean
    function add_item(current_pack, item_list, type_table, generate)
        local table_index = generate:random(1, #type_table)
        for k = 1, #type_table do
            local ttype = type_table[table_index]
            if (ttype == "fluid" and current_pack.fluidCount < 2) or ttype ~= "fluid" then
                local item_index = generate:random(1, #item_list[ttype])
                for i = 1, #item_list[ttype] do
                    local item = table.deepcopy(item_list[ttype][item_index])
                    if addToDict(current_pack.ingredients, item.name, item) then
                        return populate_Item(item, generate, ttype, current_pack)
                    else
                        item_index = (item_index % #item_list[ttype]) + 1
                    end
                end
            end
            table_index = (table_index % #type_table) + 1
        end
        return false
    end

    ---@param name string
    ---@return table
    function initRecipe(name)
        local recipe = {}
        recipe.name = name
        recipe.fluidCount = 0
        recipe.ingredients = {}
        return recipe
    end

    ---@param fluidCount integer
    ---@return string
    function calc_crafting_category(fluidCount)
        if fluidCount == 0 then
            return "crafting"
        end
        if fluidCount == 1 then
            return "crafting-with-fluid"
        end
        return "chemistry"
    end

    --- calculated the cost of the recipe it self
    ---@param name string
    ---@return integer
    function calc_cost(name)
        if cost_table[name] then
            return cost_table[name]
        end

        local recipe = util.find_recipe(name)
        if not recipe then
            return 50
        end

        local current_cost = 0
        local hasWoodIngredient = false -- Flag to check if there's a wood ingredient


        for _, ing in ipairs(util.get_ingredients(recipe)) do
            local cost = calc_cost(ing.name)
            current_cost = current_cost + cost * ing.amount
            if lookup:isGrown(ing.name) then
                hasWoodIngredient = true
            end
        end

        local total_cost = math.ceil(current_cost / get_count(recipe))
        cost_table[name] = total_cost
        if hasWoodIngredient then
            lookup.grown[name] = true
        end
        return total_cost
    end

    --- needed to adjust the recipe cost by the amout it creates
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

    --- returns 1 if the player does not want it to be balanced
    ---@param name string
    ---@param ingredients table
    ---@param balance boolean
    ---@return integer
    function calc_result_count(name, ingredients, balance)
        if balance == true then
            local pack_cost = cost_table[name]
            local ingredients_cost = 0
            for _, ing in ipairs(ingredients) do
                ingredients_cost = ingredients_cost + cost_table[ing.name] * ing.amount
            end
            return math.ceil(ingredients_cost / pack_cost)
        end
        return 1
    end

    --- written as I intend to expand this function in future
    ---@param prototype table
    ---@param balance boolean
    ---@return table
    function build_results(prototype, balance)
        local result_count = calc_result_count(prototype.name, prototype.ingredients, balance)
        local result = {
            name = prototype.name,
            amount = result_count,
            type = "item"
        }
        return { result }
    end

    ---comment
    ---@param tier_list table
    ---@param accumulator table
    ---@param generate table
    function populate_ingredients(tier_list, accumulator, generate, tier)
        local max_tier = tier
        local min_tier = config.inTier and tier or 1
        local ingredientCount = generate:random(1, 5)
        local currentIngredientCount = 0
        while currentIngredientCount < ingredientCount do
            local current_tier = generate:random(min_tier, max_tier)
            local item_lists = tier_list[current_tier].items
            local type_table = get_type_table(item_lists, accumulator.fluidCount)
            if not add_item(accumulator, item_lists, type_table, generate) then
                ingredientCount = (ingredientCount >= 0) and (ingredientCount - 1) or 0
            end
            currentIngredientCount = currentIngredientCount + 1
        end
    end

    --- this function is for now a little overloaded
    ---@param tier_list table
    ---@param generate table
    ---@return table
    function generate_prototype(tier_list, generate)
        local recipes = {}
        config.types_table = populate()
        for tier = 1, #tier_list do
            local recipe = initRecipe(tier_list[tier].name)
            populate_ingredients(tier_list, recipe, generate, tier)
            recipe.ingredients = dictToList(recipe.ingredients)
            recipe.category = calc_crafting_category(recipe.fluidCount)
            recipe.results = build_results(recipe, config.isBalanced)
            recipe.fluidCount = nil
            table.insert(recipes, recipe)
        end
        return recipes
    end

    -- ========================================================================

    local recipes = {}
    for _, tech in pairs(data.raw.technology) do
        add_tiered_recipe(recipes, tech)
    end

    for _, recipe in pairs(data.raw.recipe) do
        if util.is_enabled(recipe) then
            local tier = 1
            if lookup:isScience(recipe.name) then
                tier = 2
            end
            addToDict(recipes, recipe.name, tier)
        end
    end

    local item_set = {}
    for key, tier in pairs(recipes) do
        local recipe = data.raw.recipe[key]
        add_results(item_set, recipe, tier)
        add_ingredients(item_set, recipe, tier)
    end
    local item_list = dictToList(item_set)
    table.sort(
        item_list,
        function(a, b)
            return a.tier < b.tier
        end
    )

    for name, cost in pairs(lookup.costs) do
        cost_table[name] = cost
    end

    for _, item in ipairs(item_list) do
        item.cost = calc_cost(item.name)
    end

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
    local prototypes = generate_prototype(tiered_item_list, gen)
    return prototypes
    -- ========================================================================
end
return calc_prototype
