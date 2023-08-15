local Set = {}

function Set.init()
    local instance = { size = 0, values = {}, order = {}}
    setmetatable(instance, { __index = Set })
    return instance
end

function Set.from_list(list)
    local new_instance = Set.init()
    for _, value in ipairs(list) do
        new_instance:add(value)
    end
    return new_instance
end

function Set:add(value)
    if value == nil then
        return false
    end
    if not self.values[value] then
        self.size = self.size + 1
        self.values[value] = self.size
        self.order[self.size] = value
        return true
    end
    return false
end

function Set:remove(value)
    if self.values[value] then
        local index = self.values[value]
        self.order[index]  = nil
        self.values[value] = nil
        self.size = self.size - 1
        return true
    end
    return false
end

function Set:to_list()
    local list = {}
    for k in self:iterate() do
        table.insert(list, k)
    end
    return list
end

function Set.intsec(this, that)
    local intsec = Set.init()
    for value in this:iterate() do
        if this.values[value] and that.values[value] then
            intsec:add(value)
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
    for value in this:iterate() do
        diff:add(value)
    end
    for value in that:iterate() do
        diff:remove(value)
    end
    return diff
end

function Set:iterate()
    local values = self.order
    local key = nil
    return function()
        key = next(values, key)
        return values[key]
    end
end

function Set.union(this, that)
    local union = Set.init()
    for value in this:iterate() do
        union:add(value)
    end
    for value in that:iterate() do
        union:add(value)
    end
    return union
end


return Set
