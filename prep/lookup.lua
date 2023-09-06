local lookup_table = {}

local function check(input, lookup)
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
    if self:isFluid(item) then
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

function lookup_table:isBase(input)
    if input == nil or self.base == nil then
        return false
    end
    for key, value in pairs(self.base) do
        if input == key then
            return true
        end
    end
    return false
end

function lookup_table:isFluid(input)
    return check(input, self.fluid)
end

function lookup_table:isRaw(input)
    return check(input, self.raw)
end

function lookup_table:isGrown(input)
    return check(input, self.grown)
end

function lookup_table:isScience(input)
    if input == nil or self.science == nil then
        return false
    end
    for key, value in pairs(self.science) do
        if input == key then
            return true
        end
    end
    return false
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
    "raw-fish",
    "wood",
    "wood-chest",
    "combat-shotgun",
    "shotgun",
    "small-electric-pole",
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

lookup_table["base"] = {
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

lookup_table["costs"] = {
    ["stack-inserter"]=940,
    ["iron-gear-wheel"]=20,
    ["electronic-circuit"]=25,
    ["advanced-circuit"]=140,
    ["fast-inserter"]=125,
    ["stack-filter-inserter"]=1065,
    ["assembling-machine-1"]=265,
    ["iron-plate"]=10,
    ["long-handed-inserter"]=85,
    ["inserter"]=55,
    ["assembling-machine-2"]=540,
    ["steel-plate"]=50,
    ["logistic-science-pack"]=70,
    ["transport-belt"]=15,
    ["steel-chest"]=400,
    ["submachine-gun"]=350,
    ["copper-plate"]=10,
    ["shotgun"]=600,
    ["wood"]=50,
    ["shotgun-shell"]=40,
    ["piercing-rounds-magazine"]=140,
    ["firearm-magazine"]=40,
    ["grenade"]=150,
    ["coal"]=10,
    ["filter-inserter"]=225,
    ["underground-belt"]=88,
    ["splitter"]=235,
    ["rail"]=33,
    ["stone"]=10,
    ["iron-stick"]=5,
    ["locomotive"]=3550,
    ["engine-unit"]=90,
    ["cargo-wagon"]=1400,
    ["train-stop"]=365,
    ["rail-signal"]=75,
    ["rail-chain-signal"]=75,
    ["car"]=1170,
    ["small-lamp"]=50,
    ["copper-cable"]=5,
    ["solar-panel"]=675,
    ["heavy-armor"]=3500,
    ["gun-turret"]=500,
    ["medium-electric-pole"]=140,
    ["big-electric-pole"]=340,
    ["steel-furnace"]=500,
    ["stone-brick"]=20,
    ["concrete"]=21,
    ["iron-ore"]=10,
    ["water"]=1,
    ["hazard-concrete"]=21,
    ["refined-concrete"]=61,
    ["refined-hazard-concrete"]=61,
    ["pipe"]=10,
    ["landfill"]=200,
    ["fast-transport-belt"]=115,
    ["fast-underground-belt"]=488,
    ["fast-splitter"]=685,
    ["stone-wall"]=100,
    ["gate"]=250,
    ["chemical-science-pack"]=330,
    ["sulfur"]=60,
    ["military-science-pack"]=245,
    ["production-science-pack"]=1072,
    ["electric-furnace"]=1400,
    ["productivity-module"]=825,
    ["utility-science-pack"]=1262,
    ["low-density-structure"]=475,
    ["processing-unit"]=825,
    ["flying-robot-frame"]=710,
    ["satellite"]=304125,
    ["accumulator"]=1020,
    ["radar"]=325,
    ["rocket-fuel"]=60,
    ["poison-capsule"]=325,
    ["slowdown-capsule"]=200,
    ["combat-shotgun"]=1450,
    ["piercing-shotgun-shell"]=230,
    ["cluster-grenade"]=1700,
    ["explosives"]=80,
    ["uranium-rounds-magazine"]=143,
    ["uranium-238"]=3,
    ["uranium-cannon-shell"]=253,
    ["cannon-shell"]=250,
    ["explosive-uranium-cannon-shell"]=333,
    ["explosive-cannon-shell"]=330,
    ["atomic-bomb"]=17390,
    ["rocket-control-unit"]=1650,
    ["uranium-235"]=3,
    ["assembling-machine-3"]=4380,
    ["speed-module"]=825,
    ["cliff-explosives"]=1000,
    ["empty-barrel"]=50,
    ["land-mine"]=53,
    ["flamethrower"]=450,
    ["flamethrower-ammo"]=550,
    ["crude-oil"]=3,
    ["flamethrower-turret"]=2350,
    ["plastic-bar"]=35,
    ["sulfuric-acid"]=9,
    ["fluid-wagon"]=1530,
    ["storage-tank"]=450,
    ["tank"]=7080,
    ["express-transport-belt"]=375,
    ["lubricant"]=3,
    ["express-underground-belt"]=1348,
    ["express-splitter"]=2525,
    ["rocket-launcher"]=275,
    ["rocket"]=125,
    ["explosive-rocket"]=285,
    ["modular-armor"]=6700,
    ["power-armor"]=38700,
    ["electric-engine-unit"]=185,
    ["power-armor-mk2"]=477400,
    ["effectivity-module-2"]=8125,
    ["speed-module-2"]=8125,
    ["laser-turret"]=3900,
    ["battery"]=200,
    ["solid-fuel"]=3,
    ["light-oil"]=3,
    ["rocket-silo"]=274000,
    ["rocket-part"]=21850,
    ["substation"]=1250,
    ["beacon"]=3850,
    ["heavy-oil"]=3,
    ["roboport"]=9450,
    ["logistic-chest-passive-provider"]=615,
    ["logistic-chest-storage"]=615,
    ["construction-robot"]=760,
    ["logistic-robot"]=990,
    ["logistic-chest-active-provider"]=615,
    ["logistic-chest-requester"]=615,
    ["logistic-chest-buffer"]=615,
    ["energy-shield-equipment"]=1200,
    ["night-vision-equipment"]=1200,
    ["belt-immunity-equipment"]=1200,
    ["energy-shield-mk2-equipment"]=18500,
    ["battery-equipment"]=1500,
    ["battery-mk2-equipment"]=29750,
    ["solar-panel-equipment"]=1205,
    ["personal-laser-defense-equipment"]=38375,
    ["discharge-defense-equipment"]=44125,
    ["discharge-defense-remote"]=25,
    ["fusion-reactor-equipment"]=188750,
    ["exoskeleton-equipment"]=14800,
    ["personal-roboport-equipment"]=12200,
    ["personal-roboport-mk2-equipment"]=153000,
    ["pump"]=150,
    ["pumpjack"]=675,
    ["oil-refinery"]=1500,
    ["chemical-plant"]=525,
    ["petroleum-gas"]=3,
    ["steam"]=2,
    ["speed-module-3"]=45450,
    ["productivity-module-2"]=8125,
    ["productivity-module-3"]=45450,
    ["effectivity-module"]=825,
    ["effectivity-module-3"]=45450,
    ["defender-capsule"]=555,
    ["distractor-capsule"]=2640,
    ["destroyer-capsule"]=11385,
    ["centrifuge"]=20600,
    ["uranium-ore"]=3,
    ["uranium-fuel-cell"]=16,
    ["nuclear-reactor"]=110500,
    ["heat-exchanger"]=1600,
    ["heat-pipe"]=700,
    ["steam-turbine"]=1700,
    ["nuclear-fuel"]=63,
    ["used-up-uranium-fuel-cell"]=3,
    ["artillery-wagon"]=10920,
    ["artillery-turret"]=7860,
    ["artillery-shell"]=2285,
    ["artillery-targeting-remote"]=1150,
    ["spidertron"]=627050,
    ["raw-fish"]=50,
    ["spidertron-remote"]=1975,
    ["red-wire"]=30,
    ["green-wire"]=30,
    ["arithmetic-combinator"]=150,
    ["decider-combinator"]=150,
    ["constant-combinator"]=75,
    ["power-switch"]=125,
    ["programmable-speaker"]=175,
    ["wooden-chest"]=100,
    ["stone-furnace"]=50,
    ["boiler"]=90,
    ["steam-engine"]=310,
    ["electric-mining-drill"]=275,
    ["burner-mining-drill"]=140,
    ["burner-inserter"]=30,
    ["offshore-pump"]=80,
    ["small-electric-pole"]=30,
    ["pistol"]=100,
    ["light-armor"]=400,
    ["pipe-to-ground"]=75,
    ["repair-pack"]=90,
    ["automation-science-pack"]=30,
    ["lab"]=510,
    ["iron-chest"]=80,
    ["copper-ore"]=10,
}

return lookup_table
