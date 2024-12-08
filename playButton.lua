PlayButton = {}

function PlayButton:new(x, y, width, height)
    local object = {
        x = x or love.graphics.getWidth() - 250,
        y = y or love.graphics.getHeight() - 150,
        width = width or 200,
        height = height or 80,
        text = "PLAY",
        isHovered = false,
        isEnabled = true
    }
    setmetatable(object, {__index = PlayButton})
    return object
end

function PlayButton:draw()
    if not self.isEnabled then return end
    
    -- Set button color based on hover state
    love.graphics.setColor(0.3, 0.6, 0.3, 1)  -- Green color
    if self.isHovered then
        love.graphics.setColor(0.4, 0.7, 0.4, 1)  -- Lighter green when hovered
    end
    
    -- Draw button background
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw button text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(self.text, self.x, self.y + self.height / 2 - 10, self.width, "center")
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function PlayButton:checkHover(x, y)
    self.isHovered = x > self.x and x < self.x + self.width and
                     y > self.y and y < self.y + self.height
    return self.isHovered
end

function PlayButton:checkClick(x, y, button)
    if button ~= 1 or not self.isEnabled then return false end
    
    return x > self.x and x < self.x + self.width and
           y > self.y and y < self.y + self.height
end
