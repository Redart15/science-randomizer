local item_list = require("prep.recipe_to_item")
local lookup = require("prep.lookup")
local tiered_item_list = {}

for i = 1, lookup.max_tier do
    local name = lookup:tier_name(i)
    tiered_item_list[i] = {
        name = name,
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
        local type = lookup:get_type(value.name)
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