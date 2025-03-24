local LinkedList = {}
LinkedList.__index = LinkedList

-- Create a new linked list
function LinkedList.new()
    local self = setmetatable({}, LinkedList)
    self.head = nil
    self.tail = nil
    self.size = 0
    return self
end

-- Create a new node
local function newNode(value)
    return {
        value = value,
        next = nil
    }
end

-- Insert at the end of the list
function LinkedList:append(value)
    local node = newNode(value)
    
    if not self.head then
        self.head = node
        self.tail = node
    else
        self.tail.next = node
        self.tail = node
    end
    
    self.size = self.size + 1
    return node
end

-- Insert at the beginning of the list
function LinkedList:prepend(value)
    local node = newNode(value)
    
    if not self.head then
        self.head = node
        self.tail = node
    else
        node.next = self.head
        self.head = node
    end
    
    self.size = self.size + 1
    return node
end

-- Remove first occurrence of a value
function LinkedList:remove(value)
    if not self.head then return false end
    
    -- Check if head needs to be removed
    if self.head.value == value then
        self.head = self.head.next
        self.size = self.size - 1
        
        -- If list is now empty
        if not self.head then
            self.tail = nil
        end
        return true
    end
    
    -- Traverse and remove
    local current = self.head
    while current.next do
        if current.next.value == value then
            current.next = current.next.next
            self.size = self.size - 1
            
            -- Update tail if last element was removed
            if current.next == nil then
                self.tail = current
            end
            return true
        end
        current = current.next
    end
    
    return false
end

-- Peek at the next element after a given value
function LinkedList:peekNext(value)
    if not self.head then
        return nil
    end
    
    local current = self.head
    while current do
        if current.value == value and current.next then
            return current.next.value
        end
        current = current.next
    end
    
    return nil
end

-- Previously added peek functions
function LinkedList:peekFirst()
    if not self.head then
        return nil
    end
    return self.head.value
end

function LinkedList:peekLast()
    if not self.tail then
        return nil
    end
    return self.tail.value
end

function LinkedList:peekAt(index)
    if index < 1 or index > self.size then
        return nil
    end
    
    local current = self.head
    for _ = 1, index - 1 do
        current = current.next
    end
    
    return current.value
end

-- Iterator function
function LinkedList:iter()
    local current = self.head
    return function()
        if current then
            local value = current.value
            current = current.next
            return value
        end
    end
end

-- Get list size
function LinkedList:getSize()
    return self.size
end

-- Check if list is empty
function LinkedList:isEmpty()
    return self.size == 0
end

-- Clear the entire list
function LinkedList:clear()
    self.head = nil
    self.tail = nil
    self.size = 0
end

return LinkedList
