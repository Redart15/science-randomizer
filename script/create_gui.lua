local mod_gui = require("mod-gui")
local create = {}

--- export recipe sctring
---@param player LuaPlayer
---@param generateString function
function create.exportField(player, generateString)
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
        text = generateString(),
    }
    text_box.style.size = { 380, 300 } -- lenght|height
    text_box.read_only = true
    text_box.word_wrap = true
end

--- create the button at the top left
---@param player LuaPlayer
function create.button(player)
    local player_globals = global.players[player.index]
    local flow_button = mod_gui.get_button_flow(player)
    if flow_button.randomizer_export_button then
        flow_button.randomizer_export_button.destroy()
    end
    mod_gui.get_button_flow(player).add {
        type = "sprite-button",
        name = "randomizer_export_button",
        sprite = "item/automation-science-pack",
        tooltip = "Export science recipe",
        style = player_globals.toggle and "yellow_slot_button" or mod_gui.button_style
    }
end

--- toggle the textfield
---@param player LuaPlayer
---@param generateString function
function create.toggle_textField(player, generateString)
    local screen_element = player.gui.screen
    if screen_element.randomizer_export_frame == nil then
        create.exportField(player, generateString)
    else
        screen_element.randomizer_export_frame.destroy()
    end
end

return create
