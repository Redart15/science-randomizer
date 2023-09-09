local util = require("libs.common.util")
local lookup = require("libs.common.lookup")
local pathprefix = "item/"
local mod_gui = require("mod-gui")


local init_globals, create_button, get_packs, initialize, toggle_textField,
create_exportField

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

function toggle_textField(player)
    local screen_element = player.gui.screen
    if screen_element.randomizer_export_frame == nil then
        create_exportField(player)
    else
        screen_element.randomizer_export_frame.destroy()
    end
end

function create_exportField(player)
    local screen_element = player.gui.screen
    local text_frame = screen_element.add {
        type = "frame",
        name = "randomizer_export_frame",
        caption = { "randomizer.export" },
    }
    text_frame.style.size = { 405, 410 } -- lenght|height
    text_frame.auto_center = true

    player.opened = text_frame

    local text_box = text_frame.add {
        type = "text-box",
        name = "randomizer_export_textbox",
        text = util.recipes2String(get_packs()),
    }
    text_box.style.size = { 380, 300 } -- lenght|height
    text_box.read_only = true
    text_box.word_wrap = true
end

function create_button(player)
    local player_globals = global.players[player.index]
    local flow_button = mod_gui.get_button_flow(player)
    if flow_button.randomizer_export_button then
        flow_button.randomizer_export_button.destroy()
    end
    mod_gui.get_button_flow(player).add {
        type = "sprite-button",
        name = "randomizer_export_button",
        sprite = pathprefix .. "automation-science-pack",
        tooltip = "Export science recipe",
        style = player_globals.toggle and "yellow_slot_button" or mod_gui.button_style
    }
    toggle_textField(player)
end

function initialize(player)
    global.players[player.index] = { toggle = false }
    create_button(player)
end

script.on_init(
    function()
        local freeplay = remote.interfaces["freeplay"]
        if freeplay then -- Disable freeplay popup-message
            if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
            if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
        end
        global.players = {}
        for _, player in pairs(game.players) do
            initialize(player)
            -- create_button(player)
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
        create_button(player)
    end
)

script.on_event(
    defines.events.on_gui_closed,
    function(event)
        local element = event.element
        if element and element.name == "randomizer_export_button" then
            local player = game.get_player(event.player_index)
            toggle_textField(player)
        end
        if element and element.name == "randomizer_export_frame" then
            local player = game.get_player(event.player_index)
            initialize(player)
        end
    end
)

script.on_event(defines.events.on_player_removed, function(event)
    global.players[event.player_index] = nil
end)
