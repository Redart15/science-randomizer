local mod_gui = require("mod-gui")
local create = {}

local function createTitlebar(gui)
    local titlebar = gui.add {
        name = "science_randomizer_titlebar",
        type = "flow",
    }
    titlebar.drag_target = gui
    titlebar.style.bottom_padding = 4

    titlebar.add {
        name = "science_randomizer_label",
        type = "label",
        style = "frame_title",
        ignored_by_interaction = true,
        caption = { "science_randomizer.export" }
    }

    local filler = titlebar.add {
        type = "empty-widget",
        style = "draggable_space_header",
        ignored_by_interaction = true,
    }
    filler.style.height = 24
    filler.style.horizontally_stretchable = true
    filler.style.right_margin = 4

    titlebar.add {
        name = "science_randomizer_close_button",
        type = "sprite-button",
        style = "frame_action_button",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        tooltip = { "gui.close-instruction" },
    }
end

local function createTextfield(gui, text)
    local text_box = gui.add {
        type = "text-box",
        name = "science_randomizer_text_box",
        text = text,
        style = "stretchable_textfield"
    }
    text_box.read_only = true
    text_box.word_wrap = true
    text_box.style.height = 250
    text_box.style.natural_width = 200
end

local function createFootbar(gui)
    local buttom_flow = gui.add {
        name = "buttom_flowt",
        type = "flow",
    }

    buttom_flow.add {
        type = "button",
        name = "science_randomizer_select_all",
        caption = { "science_randomizer.selectAll" }
    }

    local filler = buttom_flow.add {
        type = "empty-widget",
        ignored_by_interaction = true,
    }
    filler.style.height = 24
    filler.style.horizontally_stretchable = true
    filler.style.right_margin = 4

    buttom_flow.add {
        type = "button",
        name = "science_randomizer_confirm",
        caption = { "science_randomizer.confirm" },
        tooltip = { "gui.close-instruction" }
    }
end

function create.exportGui(player, text)
    local player_globals = global.players[player.index]
    local screen_element = player.gui.screen
    local main_frame = screen_element.add {
        name = "science_randomizer_main_frame",
        type = "frame",
        direction = "vertical",
    }
    main_frame.style.natural_width = 400
    main_frame.auto_center = true
    player.opened = main_frame

    player_globals.main_frame = main_frame
    createTitlebar(main_frame)
    createTextfield(main_frame, text)
    createFootbar(main_frame)
end

--- create the button at the top left
---@param player LuaPlayer
function create.button(player)
    local flow_button = mod_gui.get_button_flow(player)
    if flow_button["science_randomizer_export_button"] then
        flow_button["science_randomizer_export_button"].destroy()
    end
    local player_globals = global.players[player.index]
    local mod_gui_button = mod_gui.get_button_flow(player).add {
        type = "sprite-button",
        name = "science_randomizer_export_button",
        sprite = "item/automation-science-pack",
        tooltip = "Export science recipe",
        style = mod_gui.button_style
    }
    player_globals.mod_gui_button = mod_gui_button
end

--- toggle the textfield
---@param player LuaPlayer
function create.toggle_textField(player, text)
    local player_globals = global.players[player.index]
    local main_frame = player_globals.main_frame
    if main_frame == nil then
        create.exportGui(player, text)
    else
        main_frame.destroy()
        player_globals.main_frame = nil
    end
end

return create
