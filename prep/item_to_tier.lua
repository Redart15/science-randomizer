local item_list = require("prep.recipe_to_item")
local lookup = require("prep.lookup")
local tiered_item_list = {}

local get_type

---comment
---@param item string
---@return string
function get_type(item)
    if lookup:isFluid(item) then
        return "fluid"
    end
    if lookup:isGrown(item) then
        return "grown"
    end
    if lookup:isRaw(item) then
        return "raw"
    end
    if lookup:isScience(item) then
        return "science"
    end
    return "item"
end


for i = 1, lookup.max_tier do
    local name = lookup:tier_name(i)
    local cost = lookup["costs"][name]
    tiered_item_list[i] = {
        name = name,
        cost = cost,
        ingredients = {
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
        local type = get_type(value.name)
        table.insert(tiered_item_list[tier].ingredients[type], value)
    end
end

for _, tier in pairs(tiered_item_list) do
    for _, lists in pairs(tier.ingredients) do
        table.sort(
            lists,
            function(this, that)
                return this.name < that.name
            end
        )
    end
end

return tiered_item_list