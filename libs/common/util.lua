local util = {}

local fix_up,
recipe2String,
items2String,
string2Attributes,
string2CraftingCat,
string2ItemType,
string2Amount,
string2Items,
string2Recipe

---comment
---@param results table
---@return table
function fix_up(results)
    local temp = {}
    for _, result in ipairs(results) do
        local item
        if result[2] ~= nil and item == nil then
            item = {
                name = result[1],
                amount = result[2]
            }
        end
        if result.name == nil and item == nil then
            item = {
                name = result,
                amount = 1
            }
        end
        if result.name ~= nil and item == nil then
            item = {
                name = result.name,
                amount = result.amount
            }
        end
        table.insert(temp, item)
    end
    return temp
end

---comment
---@param recipe table
---@return table
function util.get_ingredients(recipe)
    if recipe == nil then
        return {}
    end
    if recipe.normal ~= nil then
        return util.get_ingredients(recipe.normal)
    end
    if recipe.ingredients ~= nil then
        return fix_up(recipe.ingredients)
    end
    return {}
end

---comment
---@param recipe table
---@return table
function util.get_results(recipe)
    if recipe.results then
        return fix_up(recipe.results)
    end
    if recipe.normal then
        return util.get_results(recipe.normal)
    end
    return fix_up({ recipe.result })
end

function util.get_category(recipe)
    if recipe.category == nil then
        return "crafting"
    end
    return recipe.category
end

function util.get_item_type(item)
    if item.type == nil then
        return "item"
    end
    return item.type
end

function util.recipes2String(recipes)
    local string = ""
    for _, recipe in ipairs(recipes) do
        string = string .. recipe2String(recipe) .. "#"
    end
    return string
end

function recipe2String(recipe)
    local name           = recipe.name
    local category       = util.get_category(recipe)
    local results        = util.get_results(recipe)
    local ingredients    = util.get_ingredients(recipe)
    local string_ing     = items2String(ingredients)
    local string_res     = items2String(results)
    local collect_string = string.format("<%s>|<%s>|%s|%s", name, category, string_ing, string_res)
    return collect_string
end

function items2String(data)
    local string = ""
    for _, item in ipairs(data) do
        string = string .. "<" .. item.name .. ">"
        string = string .. "<" .. item.amount .. ">"
        string = string .. "<" .. util.get_item_type(item) .. ">"
    end
    return string
end

function string2Attributes(input)
    local strings = {}
    local count = 1
    for match in input:gmatch("[^|]+") do
        strings[count] = {}
        for submatch in match:gmatch("<(.-)>+") do
            table.insert(strings[count], submatch)
        end
        count = count + 1
    end
    return strings
end

function string2CraftingCat(string)
    local check = false
    check = check or string == "crafting"
    check = check or string == "crafting-with-fluid"
    check = check or string == "chemistry"
    if check then
        return string
    else
        error(string.format("recipe crafting category is not supported: %s", string))
    end
end

function string2ItemType(string)
    if string == "item" or string == "fluid" then
        return string
    else
        error(string.format("item type is not supported: %s", string))
    end
end

function string2Amount(string)
    local num = tonumber(string)
    if not num or num ~= math.floor(num) then
        error(string.format("item amount is not an interger: %s", string))
    end
    return num
end

function string2Items(strings)
    local temps = {}
    for i = 1, #strings, 3 do
        local temp = {}
        temp.name = strings[i]
        temp.type = string2ItemType(strings[i + 2])
        temp.amount = string2Amount(strings[i + 1])
        table.insert(temps, temp)
    end
    return temps
end

function string2Recipe(input)
    local pack = {}
    local subStrings = string2Attributes(input)
    if #subStrings == 4 and #subStrings[3] % 3 == 0 and #subStrings[4] % 3 == 0 then
        pack.name = subStrings[1][1]
        pack.category = string2CraftingCat(subStrings[2][1])
        pack.ingredients = string2Items(subStrings[3])
        pack.results = string2Items(subStrings[4])
    else
        error("string is not formatted, correctly")
    end
    return pack
end

function util.string2Recipes(input)
    local temp = {}
    for match in input:gmatch("(.-)#") do
        local recipe = string2Recipe(match)
        table.insert(temp, recipe)
    end
    return temp
end

return util
