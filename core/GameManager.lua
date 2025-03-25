-- core/GameManager.lua
local UIManager = require("core.UIManager")
local EventManager = require("core.EventManager")
local RunManager = require("core.RunManager")
local Player = require("entities.player")
local CONFIG = require("utils.config")
local BattleSystem = require("battle.BattleSystem")
local StateManager = require("core.StateManager")
local GameManager = {}
GameManager.__index = GameManager

-- TODO:
-- GameManager should handle creation of all objects
-- State manager should hanle all state, and pass views to any object that needs state
-- Runcontent should be in state manager and not exist
--
function GameManager:new()
	local manager = {

		eventManager = EventManager:new(),
		stateManager = StateManager:new(),
		-- battleSystem = BattleSystem:new(),
		-- gamePerspective = 2d-Down , 2d-Lef, 3d
		player = nil,
		runContent = nil,
		currentPath = nil,
		-- manager.stateManager = StateManager:new()
		currentState = "MAIN_MENU",
		uiManager = nil,
	}

	setmetatable(manager, GameManager)
	manager.stateManager:init(CONFIG)
	manager.player = Player:new("player", manager.stateManager)
	manager:setupPathRequestHandler()
	manager.runContent = RunManager:new(manager.eventManager, manager.stateManager, manager.player)

	manager.uiManager = UIManager:new(manager.eventManager, manager.stateManager, manager.player)
	manager.eventManager:on(EventManager.Types.STATE_CHANGED, function(newState)
		manager:transitionToState(newState)
	end)

	return manager
end

function GameManager:setupPathRequestHandler()
	self.eventManager:on(EventManager.Types.REQUEST_CURRENT_RUN_PATH, function()
		local currentPath = self.stateManager:get("run.currentPath")
		self.stateManager:set("run.currentPath", currentPath)
		self.eventManager:emit(EventManager.Types.CURRENT_RUN_PATH_RESPONSE, { currentPath = currentPath })
	end)
end

function GameManager:transitionToState(newState)
	self.stateManager:set("currentScreen", newState)
	self.eventManager:emit("PreStateChange", self.currentState)

	-- You can add more specific state transition logic here
	self.eventManager:emit("PostStateChange", newState)
end

function GameManager:start()
	-- Initial game setup
	self.uiManager:SetCurrentScreen("MAIN_MENU")
end

function GameManager:draw()
	self.uiManager:Draw()
	love.graphics.print("Current state: " .. self.currentState, 10, 10)
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

function GameManager:updateBattle(dt) end

return GameManager
