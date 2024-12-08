ImageHelper = {}

function ImageHelper:new()
    local object = {
        img = nil,
        width = 0,
        height = 0,
    originalWidth = 0,
    originalHeight = 0,
        scale = 1,
        x = 0,
    y = 0
        
            
    }
    setmetatable(object, {__index = ImageHelper})
    return object
end


function ImageHelper:LoadImage(path)
    self.img = love.graphics.newImage(path)
    self.width , self.height = self.img:getDimensions()
    return self
end


