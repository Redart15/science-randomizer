-- require("prototype.recipe")
local lookup = require("libs.common.lookup")
local util = require("libs.common.util")
local calc_prototype = require("prep.calc_prototype")


local read_settings


function read_settings(config)
    local temp = {}
    temp.seed = settings.startup[config .. "random-seed"].value
    temp.allowFluid = settings.startup[config .. "allow-fluid"].value
    temp.allowRaw = settings.startup[config .. "allow-raw"].value
    temp.allowScience = settings.startup[config .. "allow-science"].value
    temp.allowGrown = settings.startup[config .. "allow-grown"].value 
    temp.isBalanced = settings.startup[config .. "balanced"].value
    temp.inTier = settings.startup[config .. "in-tier"].value
    temp.setRecipe = settings.startup[config .. "set-packs"].value
    return temp
end

local config = read_settings("Redart-Science-Randomizer-")
local prototypess = calc_prototype(config)
print("hi")
-- local data = data.raw.recipe["automation-science-pack"]
-- -- local table_string = recipe2String(data)
-- -- print(table_string)
-- print("hi")
