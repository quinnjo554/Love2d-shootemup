local love = require "love"
-- core/GameManager.lua
local Player = require "entities.Player"
local LevelManager = require "core.RunManager"
--local UIManager = require "ui.UIManager"

local StateManager = {}
StateManager.__index = StateManager

function StateManager:new()
    local manager = setmetatable({}, self)
    -- Initialize core game systems
    manager.stateManager = StateManager:new()
    manager.player = Player:new("DefaultPlayer")
    manager.levelManager = LevelManager:new()
  --  manager.uiManager = UIManager:new()
    
    -- Current game state tracking
    manager.currentState = "MAIN_MENU"
    manager.currentBattle = nil
    
    return manager
end

return StateManager
