local love = require "love"
local GameManager = require "core.GameManager"

local gameManager

function love.load()
    -- Initialize the game manager
     local width, height = love.window.getDesktopDimensions()
    
    -- Set the window to fullscreen
    love.window.setMode(width, height, {
        fullscreen = true,
        fullscreentype = "desktop"
    })
    gameManager = GameManager:new()
    gameManager:start()
end

function love.update(dt)
    -- Central update loop
    gameManager:update(dt)
end

function love.draw()
    -- Delegate drawing to UI manager
    gameManager:draw()
end

-- Input handling
function love.mousepressed(x, y, button)
  gameManager:handleMousePress(x, y, button)
end

function love.keypressed(key)
 --   gameManager:handleKeyPress(key)
end

function love.quit()
    -- Save game on exit
  --  gameManager:saveGame()
end

