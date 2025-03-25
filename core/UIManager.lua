-- core/UIManager.lua
local MainMenuUI = require("ui/MainMenuUI")
local LevelSelectUI = require("ui/LevelSelectUI")
local BattleUI = require("ui.BattleUi")
local CreateCommonBackgrounds = require("utils.sharedBackgrounds.sharedBackgrounds")
local EventManager = require("core.EventManager")

local UIManager = {}
-- Create shared backgrounds once
local sharedBackgrounds = CreateCommonBackgrounds()

function UIManager:new(eventManager, stateManager, player)
	local object = {
		eventManager = eventManager,
		stateManager = stateManager,
		currentScreen = nil,
		player = player,

		-- Screen components
		mainMenu = nil,
		level = nil,
		battle = nil,
	}

	setmetatable(object, { __index = UIManager })

	-- Initialize UI screens with state manager
	object.mainMenu = MainMenuUI:new(object.eventManager, stateManager, sharedBackgrounds)
	object.level = LevelSelectUI:new(object.eventManager, stateManager, sharedBackgrounds)
	object.battle = BattleUI:new(object.eventManager, stateManager, player)

	-- Subscribe to state changes
	stateManager:subscribe("currentScreen", function(newScreen)
		object:SetCurrentScreen(newScreen)
	end)

	return object
end

function UIManager:SetCurrentScreen(screen)
	if screen == "MAIN_MENU" then
		self.currentScreen = self.mainMenu
	elseif screen == "DECK_BUILDER" then
		self.currentScreen = self.deckBuilder
	elseif screen == "BATTLE" then
		self.currentScreen = self.battle
	elseif screen == "LEVEL" then
		self.currentScreen = self.level
	end
end

function UIManager:handleMousePress(x, y, button)
	if self.currentScreen and self.currentScreen.handleMousePress then
		self.currentScreen:handleMousePress(x, y, button)
	end
end

function UIManager:HandleMouseMoved(x, y)
	if self.currentScreen and self.currentScreen.handleMouseMoved then
		self.currentScreen:handleMouseMoved(x, y)
	end
end

function UIManager:Update(dt, mouse_x, mouse_y)
	if self.currentScreen and self.currentScreen.update then
		self.currentScreen:update(dt, mouse_x, mouse_y)
	end
end

function UIManager:Draw()
	if self.currentScreen and self.currentScreen.draw then
		self.currentScreen:draw()
	end
end

return UIManager
