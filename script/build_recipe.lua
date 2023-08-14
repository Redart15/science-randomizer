local Set = require("data_structs.Set")

local starts = require("build_graph")
local science_sort = require("script.get_order")(starts)
local tiers = require("build_tiers")(science_sort)
print("done")

