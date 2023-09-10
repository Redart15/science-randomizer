local Set = {}

function Set.init()
    local instance = { size = 0, values = {}}
    setmetatable(instance, { __index = Set })
    function instance:isSet()
        return true
    end
    return instance
end

function Set.from_list(list)
    local new_instance = Set.init()
    for index, key in ipairs(list) do
        new_instance:add(key, index)
    end
    return new_instance
end

function Set:add(key, value)
    if key == nil or value == nil then
        return false
    end
    if not self.values[key] then
        self.size = self.size + 1
        self.values[key] = value
        return true
    end
    return false
end

function Set:to_list()
    local list = {}
    for _, value in pairs(self.values) do
        table.insert(list, value)
    end
    return list
end

return Set
