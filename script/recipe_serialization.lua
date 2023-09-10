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

    function string2Attributes(string)
        local strings = {}
        local count = 1
        for match in string:gmatch("[^|]+") do
            strings[count] = {}
            for submatch in match:gmatch("(.-)>+") do
                table.insert(strings[count], submatch)
            end
            count = count + 1
        end
        return strings
    end

    function string2CraftingCat(string)
        local check = false
        -- string can be nil has to be caught
        check = check or string == "crafting"
        check = check or string == "crafting-with-fluid"
        check = check or string == "chemistry"
        if check then
            return string
        else
            error(string.format(
            "Recipe-Crafting-Category is not supported. Supported crafting categories are \"crafting\",\"crafting-with-fluid\",\"chemistry\":%s\nInput string:\n%s", string, input))
        end
    end

    function string2ItemType(string)
        if string == "item" or string == "fluid" then
            return string
        else
            error(string.format("Item type is not supported: %s\nInput string:\n%s", string, input))
        end
    end

    function string2Amount(string)
        local num = tonumber(string)
        if not num or num ~= math.floor(num) then
            error(string.format("Item amount is not an interger: %s\nInput string:\n%s", string, input))
        end
        return num
    end

    function checkItem(string)
        local check = false
        for ptype in pairs(defines.prototypes.item) do
            for name, _ in pairs(data.raw[ptype]) do
                check = check or name == string
            end
          end
        if not check then
            error(string.format("Item is not avaible. Please check if the associated mod is enabled: %s\nInput string:\n%s", string, input))
        end
        return string
    end

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

    function string2Recipe(string)
        local pack = {}
        local subStrings = string2Attributes(string)
        if #subStrings == 4 and #subStrings[3] % 3 == 0 and #subStrings[4] % 3 == 0 then
            pack.name = subStrings[1][1]
            pack.category = string2CraftingCat(subStrings[2][1])
            pack.ingredients = string2Items(subStrings[3])
            pack.results = string2Items(subStrings[4])
        else
            error(string.format("String is formated incorrectly:%s.\nInput string:\n%s",string, input))
        end
        return pack
    end

    local temp = {}
    for match in input:gmatch("(.-)#") do
        local recipe = string2Recipe(match)
        table.insert(temp, recipe)
    end
    return temp
end

function io_prototype.recipe_serialization(recipes)
    local recipe2String,
    items2String

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

    function items2String(data)
        local string = ""
        for _, item in ipairs(data) do
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
