local Queue = {}

function Queue.init()
    local instance = {head = 1, tail = 0}
    setmetatable(instance, { __index = Queue })
    return instance
end

function Queue:push(value)
    if value == nil then
        return false
    end
    local tail = self.tail + 1
    self.tail = tail
    self[tail] = value
end

function Queue:pop()
    local head = self.head
    if head > self.tail then
        return nil
    end
    local value = self[head]
    self[head] = nil
    self.head = head + 1
    return value
end

function Queue:empty()
    return (self.tail - self.head) == -1
end


return Queue