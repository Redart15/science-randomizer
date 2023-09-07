require("libs.random.randomlua")
-- local tier_list = require("prep.item_to_tier")
local tier_list = require("prep.calc_prototype")
local set = require("libs.modss.Set")
local config = "Redart-Science-Randomizer-"
local base64 = require("libs.base64.base64")
local fluidMuliplier = 20

local return_list = {
    item_list  = tier_list,
    settings = {},
}

local read_settings,
get_prototypes,
generate_prototype,
populate,
get_type_table,
add_item,
decode -- not implemented yet

function read_settings()
    local temp = {}
    temp.seed = settings.startup[config .. "random-seed"].value
    temp.allowFluid = settings.startup[config .. "allow-fluid"].value
    temp.allowRaw = settings.startup[config .. "allow-raw"].value
    temp.allowScience = settings.startup[config .. "allow-science"].value
    temp.allowGrown = settings.startup[config .. "allow-grown"].value
    temp.isBalanced = settings.startup[config .. "balanced"].value
    temp.inTier = settings.startup[config .. "in-tier"].value
    temp.startup = settings.startup[config .. "string-setting"]
    return temp
end

function get_prototypes()
    return_list.settings = read_settings()
    local setting = return_list.settings
    local gen = mwc(setting.seed)
    if setting.startup == nil or setting.startup == "" then
        return generate_prototype(setting, gen)
    end
    decode(setting.startup)
end

function decode(string)
    local decoded = base64.dec(string)
end


function populate(setting)
    local temp = { "item", }
    if setting.allowFluid then
        table.insert(temp, "fluid")
    end
    if setting.allowRaw then
        table.insert(temp, "raw")
    end
    if setting.allowScience then
        table.insert(temp, "science")
    end
    if setting.allowGrown then
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

function generate_prototype(setting, generate)
    local settings_type_table = populate(setting)
    for tier = 1, #tier_list do
        tier_list[tier].ingredients = set.init()
        tier_list[tier].fluidCount = 0
        local max_tier = tier
        local min_tier = tier
        if setting.inTier == false then
            min_tier = 1
        end
        local ingredientCount = generate:random(1, 5)
        while tier_list[tier].ingredients.size < ingredientCount do
            local current_tier = generate:random(min_tier, max_tier)
            local item_lists = tier_list[current_tier].items
            local type_table = get_type_table(settings_type_table, item_lists, tier_list[tier].fluidCount)
            if not add_item(tier_list[tier], item_lists, type_table, generate) then
                ingredientCount = (ingredientCount >= 0) and (ingredientCount - 1) or 0
            end
        end
        tier_list[tier].ingredients = tier_list[tier].ingredients:to_list()
    end
end

get_prototypes()
return return_list