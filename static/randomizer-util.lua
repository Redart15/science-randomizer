local util = {}

local fix_up

--- ingredients/results can be saves as tables, arrays or single values
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

--- only need normal tabl
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

--- only need normal table
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

---@param recipe table
---@return string
function util.get_category(recipe)
    if recipe.category == nil then
        return "crafting"
    end
    return recipe.category
end

---@param item table
---@return string
function util.get_item_type(item)
    if item.type == nil then
        return "item"
    end
    return item.type
end

---@param recipe_name any
---@return unknown
function util.find_recipe(recipe_name)
    do
        local recipe = data.raw.recipe[recipe_name]
        if recipe ~= nil then
            return recipe
        end
    end
    for _, recipe in pairs(data.raw.recipe) do
        local results = util.get_results(recipe)
        for _, result in ipairs(results) do
            if result.name == recipe_name then
                return recipe
            end
        end
    end
    return nil
end

return util
