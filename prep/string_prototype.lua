local util = require("libs.common.util")

local recipe2String, items2String

function recipe2String(nameRecipe)
    local name, category, results, ingredients
    do
        local recipe = data.raw.recipe[nameRecipe]
        if recipe == nil then
            return ""
        end
        name        = recipe.name
        category    = recipe.get_category(recipe)
        results     = util.get_results(recipe)
        ingredients = util.get_ingredients(recipe)
    end
    local string_ing = items2String(ingredients)
    local string_res = items2String(results)
    local collect_string = string.format("{%s,%s,%s,%s}", name, category, string_ing, string_res)
    return collect_string
end

function items2String(data)
    local string = "{"
    for index, item in ipairs(data) do
        string = string .. item.name .. ","
        string = string .. item.amount .. ","
        string = string .. item.type
        if index < #data then
            string = string .. ","
        end
    end
    return string .. "}"
end

return util
