local function create_prototypes(prototypes)
    local data = data.raw.recipe
    for _, prototype in ipairs(prototypes) do
        local recipe = data[prototype.name]
        recipe.ingredients = prototype.ingredients
        recipe.results = prototype.results
        recipe.category = prototype.category
    end
end

return create_prototypes
