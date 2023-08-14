local Set = {}

function Set.init()
    local instance = {}
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
    if not self[value] then
        self[value] = true
        return true
    end
    return false
end

function Set:remove(value)
    if self[value] then
        self[value] = nil
        return true
    end
    return false
end

function Set:to_list()
    local list = {}
    for k, _ in pairs(self) do
        table.insert(list, k)
    end
    return list
end

function Set.intsec(this, that)
    local intsec = Set.init()
    for value, _ in pairs(this) do
        if this[value] == that[value] then
            intsec:add(value)
        end
    end
    return intsec
end

function Set:empty()
    local count = 0
    for value, _ in pairs(self) do
        count = count + 1
        if count > 0 then
            break
        end
    end
    return count == 0
end

function Set.diff(this, that)
    local diff = Set.init()
    if this == nil then
        return diff
    end
    if that == nil then
        return this
    end
    for value, _ in pairs(this) do
        diff:add(value)
    end
    for value, _ in pairs(that) do
        diff:remove(value)
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

return Set
