


require("libs.random.randomlua")
local Set = require("libs.data_structs.Set")
local prep = "prototype.science-randomizer.prep."
local config = "Redart-Science-Randomizer-"

local seed = settings.startup[config .. "random-seed"].value
local min = settings.startup[config .. "min-ingredients"].value
local max = settings.startup[config .. "max-ingredients"].value

local fluid_multi = 20
local gen = mwc(seed)

local get_type, type_multy
function get_type(name)
    local fluid = data.raw.fluid
    if fluid[name] then
        return "fluid"
    end
    return "item"
end

function type_multy(type)
    if type == "fluid" then
        return fluid_multi
    end
    return 1
end

local starts = require(prep .. "build_graph")
local science_sort = require(prep .. "get_order")(starts)
local tiers = require(prep .. "build_tiers")(science_sort)

local recipes = {}
for tier, value in ipairs(tiers) do
    local size = value.items.size

    if max > size then
        max = size
    end
    if min > max then
        min = max
    end
    -- need to figues a way to adjust for fluids as well


    local items = value.items.order
    for _, recipe in ipairs(value.name) do
        local components_count = gen:random(min, max) -- caping thr bottom seemsd a bit overkill, min 2 ingredient seems better
        local recipe_set = Set.init()
        local fluid_count = 0
        local count = 0
        local category = "crafting"
        local recipe_list = {}
        local fail_safe = 0 --cause I am to lazy seperating fluids out
        while components_count > count and fail_safe < 10 do
            local index = gen:random(1, size)
            local item = items[index]
            local itype = get_type(item)
            if itype ~= "fluid" then
                if  recipe_set:add(item)  then
                    table.insert(recipe_list, {name=item, type=itype, amount=-1})
                    count = count + 1
                    fail_safe = 0
                end         
            elseif fluid_count < 2 then
                if  recipe_set:add(item)  then
                    table.insert(recipe_list, {name=item, type=itype, amount=-1})
                    count = count + 1
                    fluid_count = fluid_count + 1
                    fail_safe = 0
                end
            else
                fail_safe = fail_safe + 1
            end
        end
        -- local ingredients = {}
        for _, item in ipairs(recipe_list) do
            item.amount = gen:random(1, 5) * type_multy(item.type)   
        end
        if fluid_count == 1 then
            category = "crafting-with-fluid"
        end
        if fluid_count == 2 then
            category = "chemistry"
        end

        recipes[recipe] = {}
        recipes[recipe].ingredients = recipe_list
        recipes[recipe].category = category
    end
end

return recipes
