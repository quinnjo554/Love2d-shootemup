-- AssetManager.lua
local AssetManager = {}
function AssetManager:new(image,x,y, width, height,speed)
    local manager = {
        image = love.graphics.newImage(image),
        x = x,
        y = y,
        width = width,
        height = height,
        speed = speed or 0,
        scaleX =  width / love.graphics.newImage(image):getWidth(),
        scaleY =  height / love.graphics.newImage(image):getHeight()
    }
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function AssetManager:update(dt)
    -- Move the image by its speed
    self.x = self.x - self.speed * dt
    
    -- Reset position to the right side when the image moves off-screen
    if self.x + (self.image:getWidth() * self.scaleX) < 0 then
        self.x = love.graphics.getWidth()
    end
end

function AssetManager:draw()
    love.graphics.draw(
        self.image, 
        self.x, 
        self.y, 
        0,  -- rotation
        self.scaleX, 
        self.scaleY
    )
    
    -- Draw a second image to create a seamless scrolling effect
    if self.speed > 0 then
      love.graphics.draw(
          self.image, 
          self.x + (self.image:getWidth() * self.scaleX), 
          self.y, 
          0,  -- rotation
          self.scaleX, 
          self.scaleY
      )
    end
    
end

return AssetManager
