local util = {}

local fix_up

--- ingredients/results can be saves as tables, arrays or single values
---@param results table --IngredientPrototype/ProductPrototype
---@return table --IngredientPrototype/ProductPrototype
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
---@param recipe table --RecipePrototype
---@return table --Array of IngredientPrototype
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
---@param recipe table --RecipePrototype
---@return table --Array of ProductPrototype
function util.get_results(recipe)
    if recipe.results then
        return fix_up(recipe.results)
    end
    if recipe.normal then
        return util.get_results(recipe.normal)
    end
    return fix_up({ recipe.result })
end

---@param recipe table --RecipePrototype
---@return string --RecipeCategoryID
function util.get_category(recipe)
    if recipe.category == nil then
        return "crafting"
    end
    return recipe.category
end

---@param item table --ItemPrototype
---@return string --string
function util.get_item_type(item)
    if item.type == nil then
        return "item"
    end
    return item.type
end

---@param recipe_name string --name of recipe
---@return table? --Optional(RecipePrototype)
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

---@param tech table --TechnologyPrototype
---@return table --array of Modifier
function util.unlocks_effects(tech)
    if tech == nil then
        return {}
    end
    if tech.effects then
        return tech.effects
    end
    return util.unlocks_effects(tech.normal)
end

---@param recipe table --RecipePrototype
---@return boolean
function util.is_enabled(recipe)
    if not recipe then
        return false
    end
    if recipe.normal then
        return util.is_enabled(recipe.normal)
    end
    return recipe.enabled == true or recipe.enabled == nil
end

return util
