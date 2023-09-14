local io_prototype = {}
local util = require("static.randomizer-util")
local lookup = require("static.randomizer-lookup")

function io_prototype.recipe_derialization(input)

    local error_messages = {
        attributesCountMismatch = "Attribute count missmatched: ",
        notASciencepack = "Only support changes to science-packs: ",
    }

    local divup_attributes,
    divup_items,
    det_crafting_category,
    det_recipe_name,
    det_item_type,
    det_item_name,
    conver2Integer,
    divup_recipes,
    det_items,
    incrementFluidCount

    ---@param string string
    ---@return table
    function divup_attributes(string)
        local strings = {}
        local count = 1
        for match in string:gmatch("[^|]+") do
            assert(match, "Prototype is empty or missing a field: " .. string)
            strings[count] = divup_items(match)
            count = count + 1
        end
        return strings
    end

    function divup_items(string)
        local temp = {}
        for submatch in string:gmatch("(.-)>+") do
            assert(submatch, "Attribute is empty: " .. string)
            table.insert(temp, submatch)
        end
        return temp
    end

    --- currently the recipes are only using these categories
    ---@param cat_table table
    ---@return string
    function det_crafting_category(cat_table, fluidCount)
        if #cat_table == 1 then
            local category = cat_table[1]
            local check = false
            check = (check or category == "crafting") and fluidCount == 0
            check = (check or category == "crafting-with-fluid") and fluidCount == 1
            check = (check or category == "chemistry") and fluidCount == 2
            if check then return category end
            error("Crafting-Category is not supported or is mismatched: " .. category)
        end
        error("Only support one crafting-type: " ..  serpent.block(cat_table))
    end

    ---@param string string
    ---@return string
    function det_item_type(string)
        if string == "item" or string == "fluid" then
            return string
        end
        error("Item-Type is not supported: " .. string)
    end

    ---@param string string
    ---@return integer
    function conver2Integer(string)
        local num = tonumber(string)
        if num and num == math.floor(num) then
            return num
        end
        error("Item amount is not an interger: " .. string)
    end

    ---@param name_table any
    ---@return string
    function det_recipe_name(name_table)
        if #name_table == 1 then
            local name = name_table[1]
            if data.raw.recipe[name] and lookup:isScience(name) then
                return name
            end
            error(error_messages.notASciencepack .. name)
        end
        error("Only support changes to science-packs: " .. serpent.block(name_table))
    end

    ---@param string string
    ---@return string
    function det_item_name(string)
        local check = false
        for ptype in pairs(defines.prototypes.item) do
            for name, _ in pairs(data.raw[ptype]) do
                check = check or name == string
            end
        end
        if check then
            return string
        end
        error("Item does not exist. Please check if the associated mod is enabled: " .. string)
    end

    function incrementFluidCount(item, ttype)
        if ttype == "fluid" then
            item.fluidCount = item.fluidCount + 1
        end
    end

    ---@param strings table
    ---@return table
    function det_items(pack, strings)
        if #strings % 3 == 0 then
            local temps = {}
            for i = 1, #strings, 3 do
                local temp = {}
                temp.name = det_item_name(strings[i])
                temp.type = det_item_type(strings[i + 2])
                temp.amount = conver2Integer(strings[i + 1])
                incrementFluidCount(pack, temp.type)
                table.insert(temps, temp)
            end
            return temps
        end
        error(error_messages.attributesCountMismatch .. string)
    end

    ---comment
    ---@param string string
    ---@return table
    function divup_recipes(string)
        local attributes = divup_attributes(string)
        local pack = {}
        if #attributes == 4 then
            pack.fluidCount = 0
            pack.name = det_recipe_name(attributes[1])
            pack.ingredients = det_items(pack, attributes[3])
            pack.category = det_crafting_category(attributes[2][1], pack.fluidCount)
            pack.results = det_items(pack, attributes[4])
            return pack
        end
        error(error_messages.attributesCountMismatch .. string)
    end

    local temp = {}
    for match in input:gmatch("(.-)#") do
        assert(match, "No match in input-string: " .. input)
        local recipe = divup_recipes(match)
        table.insert(temp, recipe)
    end
    return temp
end

-- ============================================================================================================
function io_prototype.recipe_serialization(recipes)
    local recipe2String,
    items2String

    ---@param recipe table
    ---@return string
    function recipe2String(recipe)
        local name           = recipe.name
        local category       = util.get_category(recipe)
        local results        = util.get_results(recipe)
        local ingredients    = util.get_ingredients(recipe)
        local string_ing     = items2String(ingredients)
        local string_res     = items2String(results)
        local collect_string = string.format("%s>|%s>|%s|%s", name, category, string_ing, string_res)
        return collect_string
    end

    ---@param items table
    ---@return string
    function items2String(items)
        local string = ""
        for _, item in ipairs(items) do
            string = string .. item.name .. ">"
            string = string .. item.amount .. ">"
            string = string .. util.get_item_type(item) .. ">"
        end
        return string
    end

    local string = ""
    for _, recipe in ipairs(recipes) do
        string = string .. recipe2String(recipe) .. "#"
    end
    return string
end

return io_prototype
