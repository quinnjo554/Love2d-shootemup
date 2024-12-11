local love = require "love"
local SpriteAnimation = require "ui.SpriteAnimation"

local CutsceneSprite = {}

function CutsceneSprite:new(options)
    -- Default configuration
    local defaultConfig = {
        -- Starting position (off-screen)
        x = -100,
        y = love.graphics.getHeight() - 100,
        
        -- Movement parameters
        speed = 100,  -- pixels per second
        targetX = love.graphics.getWidth() / 2,
        targetY = love.graphics.getHeight() / 2,
        
        -- Sprite animation details
        spriteSheet = "sprites/ui/Player-Sheet.png",
        frameWidth = 78,   -- Add frame width explicitly
        frameHeight = 78,  -- Add frame height explicitly
        spriteFrames = 0.1,
        spriteScale = 1,
        
        -- Movement states
        movementState = "offscreen"  -- States: offscreen, moving, centered
    }
    
    -- Merge provided options with default configuration
    local config = {}
    for k, v in pairs(defaultConfig) do
        config[k] = options and options[k] ~= nil and options[k] or v
    end
    
    -- Create the sprite object
    local object = {
        x = config.x,
        y = config.y,
        speed = config.speed,
        targetX = config.targetX,
        targetY = config.targetY,
        movementState = config.movementState,
        spriteScale = config.spriteScale
    }
    
    -- Set metatable
    setmetatable(object, self)
    self.__index = self
    
    -- Initialize sprite animation with correct parameters
    object.pauSprite = SpriteAnimation:new(
        config.spriteSheet, 
        config.frameWidth,   -- Pass frame width 
        config.frameHeight,  -- Pass frame height
        config.spriteFrames
    )
    
    return object
end

-- Update sprite position and movement
function CutsceneSprite:update(dt)
    self.pauSprite:update(dt)
    if self.movementState == "moving" then
        local currentX, currentY = self.x, self.y
        
        -- Calculate direction vector
        local dx = self.targetX - currentX
        local dy = self.targetY - currentY
        
        -- Calculate distance
        local distance = math.sqrt(dx*dx + dy*dy)
        
        -- If close to target, stop moving
        if distance < 10 then
            self.x = self.targetX
            self.y = self.targetY
            self.movementState = "centered"
        else
            -- Normalize and move
            local moveDistance = self.speed * dt
            local ratio = moveDistance / distance
            
            self.x = currentX + dx * ratio
            self.y = currentY + dy * ratio
        end
        
        -- Update sprite animation
    end
end

-- Draw the sprite
function CutsceneSprite:draw()
    if self.pauSprite and (self.movementState == "moving" or self.movementState == "centered") then
        self.pauSprite:draw(self.x, self.y, self.spriteScale)
    end
end

-- Start the cutscene movement
function CutsceneSprite:startCutscene()
    if self.movementState == "offscreen" then
        self.movementState = "moving"
    end
end

-- Reset sprite to initial state
function CutsceneSprite:reset()
    self.x = -100
    self.y = love.graphics.getHeight() - 100
    self.movementState = "offscreen"
end

return CutsceneSprite
