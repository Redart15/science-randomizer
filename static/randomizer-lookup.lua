local lookup_table = {}

local isFluid, isRaw, isGrown, isScience, icheck, check

function check(input, lookup)
    if input == nil or not lookup[input] then
        return false
    end
    return true
end

function icheck(input, lookup)
    if input == nil or lookup == nil then
        return false
    end
    for _, value in ipairs(lookup) do
        if input == value then
            return true
        end
    end
    return false
end

function lookup_table:get_type(item)
    local data = data.raw.fluid
    if self:isFluid(item) or data[item] then
        return "fluid"
    end
    if self:isGrown(item) then
        return "grown"
    end
    if self:isRaw(item) then
        return "raw"
    end
    if self:isScience(item) then
        return "science"
    end
    return "item"
end

function lookup_table:isFluid(input)
    return icheck(input, self.fluid)
end

function lookup_table:isRaw(input)
    return icheck(input, self.raw)
end

function lookup_table:isGrown(input)
    return check(input, self.grown)
end

function lookup_table:isScience(input)
    return check(input, self.science)
end

function lookup_table:tier_name(input)
    if input == nil or input < 0 or input > self.max_tier then
        return ""
    end
    for key, tier in pairs(self.science) do
        if input == tier then
            return key
        end
    end
    return ""
end

lookup_table["science"] = {
    ["automation-science-pack"] = 1,
    ["logistic-science-pack"] = 2,
    ["military-science-pack"] = 3,
    ["chemical-science-pack"] = 4,
    ["production-science-pack"] = 5,
    ["utility-science-pack"] = 6,
}

lookup_table.max_tier = 6

lookup_table["raw"] = {
    "coal",
    "copper-ore",
    "iron-ore",
    "stone",
    "uranium-ore"
}

lookup_table["grown"] = {
    ["raw-fish"] = true,
    ["wood"] = true,
}

lookup_table["fluid"] = {
    "crude-oil",
    "heavy-oil",
    "light-oil",
    "lubricant",
    "petroleum-gas",
    "steam",
    "sulfuric-acid",
    "water",
}

lookup_table["costs"] = {
    ["crude-oil"] = 3,
    ["steam"] = 2,
    ["water"] = 1,
    ["coal"] = 10,
    ["copper-ore"] = 10,
    ["iron-ore"] = 10,
    ["stone"] = 10,
    ["raw-fish"] = 50,
    ["wood"] = 50
}

return lookup_table