local lookup = require("static.randomizer-lookup")
local create = require("script.create_gui")
local mod_gui = require("mod-gui")
local recipes_serialization = require("script.recipe_serialization").recipes_serialization

local serializationPacks,
closeInterface,
initialize,
selectText,
printSeed

function serializationPacks()
    local function get_packs()
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

    local packs = get_packs()
    return recipes_serialization(packs)
end

function closeInterface(event)
    local element = event.element
    local closeTextfield = not element == nil
    closeTextfield = closeTextfield and element.valid
    closeTextfield = closeTextfield or element.name == "science_randomizer_export_button"
    closeTextfield = closeTextfield or element.name == "science_randomizer_close_button"
    closeTextfield = closeTextfield or element.name == "science_randomizer_confirm"
    if closeTextfield then
        local player = game.get_player(event.player_index)
        create.toggle_textField(player, serializationPacks())
        return
    end
end

function selectText(event)
    local element = event.element
    local selectTextfield = element ~= nil
    selectTextfield = selectTextfield and element.valid
    selectTextfield = selectTextfield and element.name == "science_randomizer_select_all"
    if selectTextfield then
        local player_globals = global.players[event.player_index]
        local textfield = player_globals.main_frame["science_randomizer_text_box"]
        textfield:select_all()
    end
end

function printSeed()
end

function initialize(player)
    global.players[player.index] = {}
    create.button(player)
end

script.on_init(function()
    -- only here for testing
    local freeplay = remote.interfaces["freeplay"]
    if freeplay then -- Disable freeplay popup-message
        if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    end
    global.players = {}
    for _, player in pairs(game.players) do
        initialize(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    initialize(player)
end)

script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.get_player(event.player_index)
    initialize(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
    closeInterface(event)
    selectText(event)
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local element = event.element
    if element and element.name == "science_randomizer_main_frame" then
        local player = game.get_player(event.player_index)
        create.toggle_textField(player, serializationPacks())
    end
end)

script.on_event(defines.events.on_player_removed, function(event)
    global.players[event.player_index] = nil
end)

script.on_configuration_changed(function(configuration_changed_data)
    if configuration_changed_data.mod_changes["science-randomizer"] then
        for _, player in pairs(game.players) do
            local player_global = global.players[player.index]
            local flow_button = mod_gui.get_button_flow(player)
            if flow_button.randomizer_export_button then
                flow_button.randomizer_export_button.destroy()
                initialize(player)
            end
            if player_global.main_frame ~= nil then
                create.toggle_textField(player, serializationPacks())
            end
        end
    end
end)
