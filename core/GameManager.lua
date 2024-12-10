-- core/GameManager.lua
-- make a visual list of logic u need to implement
-- make a visual list of logic u need to implement
local UIManager = require "core.UIManager"
local GameManager = {}
GameManager.__index = GameManager

function GameManager:new()
    local manager = setmetatable({}, self)
    manager.uiManager = UIManager:new(manager)
   -- manager.stateManager = StateManager:new()
    manager.currentState = "MAIN_MENU"
    
    return manager
end

function GameManager:transitionToState(newState)
    self.currentState = newState
    -- State transition logic
    local stateTransitions = {
        ["MAIN_MENU"] = function() 
        self.uiManager:SetCurrentScreen("MAIN_MENU")
        end,
        ["LEVEL"] = function() 
            self.uiManager:SetCurrentScreen("LEVEL")
            self.currentState = "LEVEL"
        end
    }
    
    if stateTransitions[newState] then
        stateTransitions[newState]()
    end
end

function GameManager:start()
    -- Initial game setup
    self.uiManager:SetCurrentScreen("MAIN_MENU")
end

function GameManager:draw()
    -- Delegate drawing to UI manager
    self.uiManager:Draw()
    -- Draw the current game state
    love.graphics.print("Current State: " .. self.currentState, 10, 10)
end

function GameManager:startBattle(levelData)
    self.currentState = "BATTLE"
    self.uiManager:SetCurrentScreen("BATTLE") -- Update the UI
end

function GameManager:update(dt)
      local mouse_x, mouse_y = love.mouse.getPosition()
      self.uiManager:Update(dt, mouse_x, mouse_y)
end

function GameManager:handleMousePress(x, y, button)
    if self.uiManager.currentScreen and self.uiManager.currentScreen.handleMousePress then
        self.uiManager.currentScreen:handleMousePress(x, y, button)
    end
end

function GameManager:updateBattle(dt)
end

return GameManager
