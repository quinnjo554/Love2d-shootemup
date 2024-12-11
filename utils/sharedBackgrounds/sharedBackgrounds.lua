local AssetManager = require "core.AssetManager"
function CreateCommonBackgrounds()
    local screenWidth, screenHeight = love.window.getDesktopDimensions()

    return {
        -- First layer: Forest background
        AssetManager:new(
            "sprites/ui/forest/1-export.png", 
            0, 0, 
            screenWidth,   -- Ensure full width
            screenHeight,  -- Ensure full height
            10             -- Parallax speed
        ),
        
        -- Second layer: Nature layer
        AssetManager:new(
            "sprites/ui/nature_5/3-export.png", 
            0, 0, 
            screenWidth, 
            screenHeight, 
            10
        ),
        
        -- Third layer: Extended background
        AssetManager:new(
            "sprites/ui/nature_5/4-export.png", 
            0, 0, 
            screenWidth * 1.5,  -- Optional: can extend slightly beyond screen
            screenHeight, 
            7
        ),
        
        -- Logo (optional, positioned relatively)
            }
end

return CreateCommonBackgrounds
