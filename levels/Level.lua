local Level = {}

function Level:new(name,img)
    local level = setmetatable({}, self)
    level.background = love.graphics.newImage(img)
    level.path = img
    level.reward = "Reward: 1000"  -- change to real object
    level.Enemies = nil
    level.levelName = name
    level.winCondition = ""
    return level
end

return Level
