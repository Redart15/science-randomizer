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


function Set:remove(key)
    if self.values[key] then
        self.values[key] = nil
        self.size = self.size - 1
        return true
    end
    return false
end

function Set.intsec(this, that)
    local intsec = Set.init()
    for key in this:iterate() do
        if this.values[key] and that.values[key] then
            intsec:add(key, this.values[key])
        end
    end
    return intsec
end

function Set:empty()
    return self.size == 0
end

function Set.diff(this, that)
    local diff = Set.init()
    if this == nil then
        return diff
    end
    if that == nil then
        return this
    end
    for key, value in pairs(this.values) do
        diff:add(key, value)
    end
    for key, value in pairs(that.values) do
        diff:remove(key, value)
    end
    return diff
end

function Set:iterate()
    local values = self.values
    local key = nil
    return function()
        key = next(values, key)
        return key
    end
end

function Set.union(this, that)
    local union = Set.init()
    for key, value in pairs(this.values) do
        union:add(key, value)
    end
    for key, value in pairs(that.values) do
        union:add(key, value)
    end
    return union
end

function Set:to_list()
    local list = {}
    for _, value in pairs(self.values) do
        table.insert(list, value)
    end
    return list
end

return Set
