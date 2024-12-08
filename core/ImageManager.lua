
local AssetManager = {}
AssetManager.__index = AssetManager

function AssetManager:new()
    local manager = setmetatable({}, self)

    manager.images = {}
    
    return manager
end

function AssetManager:addNewAsset(imageName, path)
    self.images[imageName] = love.graphics.newImage(path)
    self.images[imageName].x = self.images[imageName]:getWidth()
end
