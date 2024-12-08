-- core/GameManager.lua
local Player = require "entities.Player"
local LevelManager = require "core.LevelManager"
local StateManager = require "core.StateManager"
local BattleSystem = require "battle.BattleSystem"
local UIManager = require "ui.UIManager"

local StateManager = {}
StateManager.__index = StateManager

function Start:new()
    local manager = setmetatable({}, self)
    -- Initialize core game systems
    manager.stateManager = StateManager:new()
    manager.player = Player:new("DefaultPlayer")
    manager.levelManager = LevelManager:new()
    manager.uiManager = UIManager:new()
    
    -- Current game state tracking
    manager.currentState = "MAIN_MENU"
    manager.currentBattle = nil
    
    return manager
end


