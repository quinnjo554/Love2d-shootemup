local AssetManager = require("core.AssetManager")

local NextButton = {}

function NextButton:new(x, y, width, height, onClickCallback)
  local object = {
    x = x,
    y = y,
    width = width or 50,
    height = height or 50,
    asset = nil,
    onClickCallback = onClickCallback,
    isHovered = false, -- Track hover state
  }
  
  -- Initialize asset with default or provided path
  object.asset = AssetManager:new(
    "sprites/ui/next.png", 
    x, 
    y, 
    object.width, 
    object.height
  )
  
  setmetatable(object, {__index = NextButton})
  return object
end

function NextButton:draw()
  if self.asset then
    -- Optionally change color if hovered
    if self.isHovered then
      love.graphics.setColor(1, 1, 0, 1) -- Highlight color (yellow)
    end
    self.asset:draw()
    love.graphics.setColor(1, 1, 1, 1) -- Reset color
  end
end

function NextButton:mousepressed(x, y, button)
  -- Only handle left mouse button
  if button ~= 1 then return false end
  
  -- Check if click is within button bounds
  if x >= self.x and x <= self.x + self.width and
     y >= self.y and y <= self.y + self.height then
    -- Call the provided callback function if it exists
    if self.onClickCallback then
      self.onClickCallback()
    end
    return true
  end
  
  return false
end

function NextButton:update(dt)
  -- Determine hover state based on mouse position
  local mx, my = love.mouse.getPosition()
  self.isHovered = mx >= self.x and mx <= self.x + self.width and
                   my >= self.y and my <= self.y + self.height
end

return NextButton
