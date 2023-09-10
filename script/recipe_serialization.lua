local io_prototype = {}
local util = require("static.randomizer-util")

function io_prototype.recipe_derialization(input)
    local string2Attributes,
    string2CraftingCat,
    string2ItemType,
    string2Amount,
    string2Items,
    string2Recipe,
    checkItem

    ---@param string string
    ---@return table
    function string2Attributes(string)
        local strings = {}
        local count = 1
        for match in string:gmatch("[^|]+") do
            strings[count] = {}
            if match == nil then
                error(string.format("String is missing value, or is malformed. Nil match in match: %s\nInput string:\n", string, input))
            end
            for submatch in match:gmatch("(.-)>+") do
                if submatch == nil then
                    error(string.format("String is missing value, or is malformed. Nil submatch in match: %s\nInput string:\n",match, input))
                end
                table.insert(strings[count], submatch)
            end
            count = count + 1
        end
        return strings
    end

    --- currently the recipes are only using these categories
    ---@param string any
    ---@return any
    function string2CraftingCat(string)
        local check = false
        check = check or string == "crafting"
        check = check or string == "crafting-with-fluid"
        check = check or string == "chemistry"
        if check then
            return string
        else
            error(string.format(
                "Recipe-Crafting-Category is not supported. Supported crafting categories are \"crafting\",\"crafting-with-fluid\",\"chemistry\":%s\nInput string:\n%s",
                string, input))
        end
    end

    ---@param string string
    ---@return string
    function string2ItemType(string)
        if string == "item" or string == "fluid" then
            return string
        else
            error(string.format("Item type is not supported: %s\nInput string:\n%s", string, input))
        end
    end

    ---@param string string
    ---@return integer
    function string2Amount(string)
        local num = tonumber(string)
        if not num or num ~= math.floor(num) then
            error(string.format("Item amount is not an interger: %s\nInput string:\n%s", string, input))
        end
        return num
    end

    ---@param string string
    ---@return string
    function checkItem(string)
        local check = false
        for ptype in pairs(defines.prototypes.item) do
            for name, _ in pairs(data.raw[ptype]) do
                check = check or name == string
            end
        end
        if not check then
            error(string.format(
                "Item is not avaible. Please check if the associated mod is enabled: %s\nInput string:\n%s", string,
                input))
        end
        return string
    end


    ---@param strings table
    ---@return table
    function string2Items(strings)
        local temps = {}
        for i = 1, #strings, 3 do
            local temp = {}
            temp.name = checkItem(strings[i])
            temp.type = string2ItemType(strings[i + 2])
            temp.amount = string2Amount(strings[i + 1])
            table.insert(temps, temp)
        end
        return temps
    end

    ---comment
    ---@param string string
    ---@return table
    function string2Recipe(string)
        local pack = {}
        local subStrings = string2Attributes(string)
        if #subStrings == 4 and #subStrings[3] % 3 == 0 and #subStrings[4] % 3 == 0 then
            pack.name = subStrings[1][1]
            pack.category = string2CraftingCat(subStrings[2][1])
            pack.ingredients = string2Items(subStrings[3])
            pack.results = string2Items(subStrings[4])
        else
            error(string.format("String is formated incorrectly:%s.\nInput string:\n%s", string, input))
        end
        return pack
    end

    local temp = {}
    for match in input:gmatch("(.-)#") do
        local recipe = string2Recipe(match)
        if match == nil then
            error(string.format("No match in input-string:%s.", input))
        end
        table.insert(temp, recipe)
    end
    return temp
end

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
