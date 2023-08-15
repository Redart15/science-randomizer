local Set = require("data_structs.Set")
require("random.randomlua")
local seed = 0
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

local starts = require("prototype.prep.build_graph")
local science_sort = require("prototype.prep.get_order")(starts)
local tiers = require("prototype.prep.build_tiers")(science_sort)

local recipe_list = {}
for tier, value in ipairs(tiers) do
    local size = value.items.size
    local items = value.items.order
    for _, recipe in ipairs(value.name) do
        local components_count = gen:random(2, 7) -- caping thr bottom seemsd a bit overkill, min 2 ingredient seems better
        local recipe_item = Set.init()
        local n = 0
        local category = "crafting"
        while components_count > n do
            local index = gen:random(1, size)
            if recipe_item:add(items[index]) then
                n = n + 1
            end
        end
        local item_list = recipe_item:to_list()
        local ingredients = {}
        -- local amount = gen:random(1, 10)
        for _, item in ipairs(item_list) do
            local itype = get_type(item)
            local amount = gen:random(1, 5) * type_multy(itype)
            -- local lamount = amount * type_multy(itype)
            if itype == "fluid" then
                category = "crafting-with-fluid"
            end
            table.insert(ingredients, { name=item, amount=amount, type=itype })
        end
        recipe_list[recipe] = {}
        recipe_list[recipe].ingredients = ingredients
        recipe_list[recipe].category = category
    end
end

return recipe_list
