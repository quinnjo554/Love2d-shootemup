-- core/GameManager.lua
local Player = require "entities.Player"
local LevelManager = require "core.LevelManager"
local StateManager = require "core.StateManager"
local BattleSystem = require "battle.BattleSystem"
local UIManager = require "ui.UIManager"

local GameManager = {}
GameManager.__index = GameManager

function GameManager:new()
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

function GameManager:start()
    -- Initial game setup
    -- self:loadSavedGame()
    self.uiManager:SetCurrentScreen("MAIN_MENU")
end

function GameManager:draw()
    self.uiManager:drawCurrentScreen()
end

function GameManager:startBattle(levelData)
    -- Create a new battle instance
    local enemy = levelData:generateEnemy()
    self.currentBattle = BattleSystem:new(self.player, enemy, levelData)
    -- Switch to battle UI
    self.currentState = "BATTLE"
    self.uiManager:showBattleScreen(self.currentBattle)
end

function GameManager:update(dt)
    -- Handle different game states
    if self.currentState == "BATTLE" then
        self:updateBattle(dt)
    elseif self.currentState == "MAIN_MENU" then
        self:updateMainMenu(dt)
    elseif self.currentState == "DECK_BUILDER" then
        self:updateDeckBuilder(dt)
    end
end

function GameManager:updateBattle(dt)
    if self.currentBattle then
        -- Update battle logic
        self.currentBattle:update(dt)
        
        -- Check for battle completion
        if self.currentBattle:isCompleted() then
            self:resolveBattle()
        end
    end
end

function GameManager:resolveBattle()
    local battleResult = self.currentBattle:getResult()
    
    -- Process player progression
    if battleResult.victory then
        self.player:addExperience(battleResult.experienceGained)
        self.levelManager:advanceToNextLevel()
    end
    
    -- Return to main menu or next level
    self.currentState = "MAIN_MENU"
    self.currentBattle = nil
end

function GameManager:loadSavedGame()
    -- Load player progress from saved state
    local savedData = self.stateManager:loadGameState()
    if savedData then
        self.player:loadProgress(savedData)
        self.levelManager:setCurrentLevel(savedData.currentLevel)
    end
end

function GameManager:saveGame()
    -- Save current game state
    local gameState = {
        player = self.player:getProgressData(),
        currentLevel = self.levelManager:getCurrentLevel()
    }
    self.stateManager:saveGameState(gameState)
end

return GameManager
