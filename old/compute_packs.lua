local Queue = require("data_structs.Queue")
local Set = require("data_structs.Set")

local get_keys,
extract_packs,
get_t0_pack,
get_items,
add_items,
get_techs,
get_tech_packs,
get_unlock_techs,
contains_only_unlock_pack


function get_keys(tiers)
    local new_table = Set.init()
    for key, _ in pairs(tiers) do
        new_table:add(key)
    end
    return new_table
end

function extract_packs(unlocks, pack_list)
    return Set.intsec(unlocks, pack_list)
end

function get_t0_pack(tiers)
    for key, value in pairs(tiers) do
        if value.tier == 0 then
            return key
        end
    end
end

function get_items(effect_list)
    local result = Set.init()
    -- local result = {}
    if effect_list == nil then
        return result
    end
    for _, value in ipairs(effect_list) do
        -- table.insert(result, value.recipe)
        result:add(value.recipe)
    end
    return result
end

function add_items(item_set, item_list)
    for value, _ in pairs(item_list) do
        item_set:add(value)
    end
end

function get_techs(postrequisites)
    if postrequisites == nil then
        return {}
    end
    local tech_list = {}
    for _, value in ipairs(postrequisites) do
        table.insert(tech_list, value)
    end
    return tech_list
end

function get_tech_packs(tech)
    local ingredients = data.raw.technology[tech].unit.ingredients
    local result_set = Set.init()
    for _, value in ipairs(ingredients) do
        result_set:add(value[1])
    end
    return result_set
end

function get_unlock_techs(tech)
    local result = Set.init()
    if data.raw.technology[tech].effects == nil then
        return result
    end
    for _, value in ipairs(data.raw.technology[tech].effects) do
        result:add(value.recipe)
    end
    return result
end

function contains_only_unlock_pack(tech, packs_set, pack_list)
    local tech_packs = get_tech_packs(tech)
    local diff = Set.diff(tech_packs, packs_set)
    local unlock_techs = get_unlock_techs(tech)
    local diff2 = Set.intsec(unlock_techs, pack_list)
    local bool = diff:empty() and diff2:empty()
    return bool
end

local setup = require("setup")
local research = Queue.init()
local check = Set.init()
local pack_list = get_keys(setup.tiers)


for value, _ in pairs(setup.starts) do
    research:push(value)
    check:add(value)
end

local items = Set.init()
local current_packs = Set.init()
do
    local pack = get_t0_pack(setup.tiers)
    current_packs:add(pack)
    add_items(items, { pack })
end
local tier = 1
local inrow = 0


while not research:empty() do
    local next = research:pop()
    if contains_only_unlock_pack(next, current_packs, pack_list) then
        inrow         = 0
        local unlocks = get_items(data.raw.technology[next].effects)
        local packs   = extract_packs(unlocks, pack_list)
        if packs:empty() then
            add_items(items, unlocks)
        else
            for value, _ in pairs(packs) do
                setup.tiers[value].items = items
                setup.tiers[value].tier = tier
            end
            items = Set.init()
            tier = tier + 1
            add_items(items, unlocks)
        end
        local techs = get_techs(data.raw.technology[next].postrequisites)
        for _, value in ipairs(techs) do
            if check:add(value) then
                research:push(value)
            end
        end
    else
        research:push(next)
        inrow = inrow + 1
    end
end

print(setup.tiers)
