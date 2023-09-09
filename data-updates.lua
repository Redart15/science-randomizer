local calc_prototype = require("script.calc_prototype")
local create_prototypes = require("prototype.recipe")
local util = require("libs.common.util")

local read_settings, get_prototype

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

function get_prototype(config)
    if config.setRecipe == "" then
        return calc_prototype(config)
    else
        return util.string2Recipes(config.setRecipe)
    end
end

local config = read_settings("Redart-Science-Randomizer-")
local prototypes = get_prototype(config)
create_prototypes(prototypes)

