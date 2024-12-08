local GameManager = require "core.GameManager"

local gameManager

function love.load()
    -- Initialize the game manager
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
    gameManager:handleKeyPress(key)
end

function love.quit()
    -- Save game on exit
    gameManager:saveGame()
end
