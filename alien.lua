
Alien = {}

function Alien:new(x, y)
    local object = {
        x = x,
        y = y,
        speed = 1  -- Alien speed (can be different from ship)
    }
    setmetatable(object, {__index = Alien})
    return object
end

function Alien:move()
    -- Simple alien movement (downward for example)
    self.y = self.y + self.speed
end
