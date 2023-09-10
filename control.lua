local lookup = require("static.randomizer-lookup")
local create = require("script.create_gui")
local recipes2String = require("script.recipe_serialization").recipe_serialization


local get_packs, generateString

function generateString()
    local packs = get_packs()
    return recipes2String(packs)
end

function get_packs()
    local recipes = game.recipe_prototypes
    local temp = {}
    for key, _ in pairs(lookup["science"]) do
        local luaRecipe = recipes[key]
        if luaRecipe ~= nil then
            local recipe = {}
            recipe.name = luaRecipe.name
            recipe.category = luaRecipe.category
            recipe.ingredients = luaRecipe.ingredients
            recipe.results = luaRecipe.products
            table.insert(temp, recipe)
        end
    end
    return temp
end

local function initialize(player)
    global.players[player.index] = { toggle = false }
    create.button(player)
end

script.on_init(
    function()
        -- only here for testing
        -- local freeplay = remote.interfaces["freeplay"]
        -- if freeplay then -- Disable freeplay popup-message
        --     if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        --     if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
        -- end
        global.players = {}
        for _, player in pairs(game.players) do
            initialize(player)
        end
    end
)

script.on_event(
    defines.events.on_player_created,
    function(event)
        local player = game.get_player(event.player_index)
        initialize(player)
    end
)

script.on_event(
    defines.events.on_player_joined_game,
    function(event)
        local player = game.get_player(event.player_index)
        initialize(player)
    end
)

script.on_event(
    defines.events.on_gui_click,
    function(event)
        local element = event.element
        if element.name ~= "randomizer_export_button" then
            return
        end
        local player = game.get_player(event.player_index)
        local player_globals = global.players[event.player_index]
        player_globals.toggle = not player_globals.toggle
        create.button(player)
        create.toggle_textField(player, generateString)
    end
)

script.on_event(
    defines.events.on_gui_closed,
    function(event)
        local element = event.element
        if element and element.name == "randomizer_export_button" then
            local player = game.get_player(event.player_index)
            create.toggle_textField(player, generateString)
        end
        if element and element.name == "randomizer_export_frame" then
            local player = game.get_player(event.player_index)
            initialize(player)
            create.toggle_textField(player, generateString)
        end
    end
)

script.on_event(defines.events.on_player_removed, function(event)
    global.players[event.player_index] = nil
end)
