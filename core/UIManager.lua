-- core/GameManager.lua
-- TODO: Take funtionality from main.lua and put it in GameManager.lua
-- TODO: Make a asset manager so you can store the image, x,y,w,z
local MainMenuUI = require("ui/MainMenuUI")
local LevelSelectUI = require("ui/LevelSelectUI")
local BattleUI = require("ui.BattleUi")
local CreateCommonBackgrounds = require("utils.sharedBackgrounds.sharedBackgrounds")
local EventManager = require("core.EventManager")

local UIManager = {}
-- Find better way to share backgrounds for main and level, I have a fix, just add the model to the main menu
local sharedBackgrounds = CreateCommonBackgrounds()

function UIManager:new(eventManager)
	local object = {
		-- deckBuilder = nil,
		currentScreen = "",
		eventManager = eventManager,
		mainMenu = nil,
		level = nil,
		battle = nil,
	}

	object.mainMenu = MainMenuUI:new(object.eventManager, sharedBackgrounds)
	-- Create LevelSelectUI with event-based transition
	object.level = LevelSelectUI:new(object.eventManager, sharedBackgrounds)

	object.battle = BattleUI:new(object.eventManager)

	setmetatable(object, { __index = UIManager })

	-- subscribe to state changes
	eventManager:on(EventManager.Types.STATE_CHANGED, function(newState)
		object:SetCurrentScreen(newState)
	end)

	return object
end
-- Main menu screen will just be Background and a button

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
	if self.currentScreen then
		self.currentScreen:update(dt, mouse_x, mouse_y)
	end
end

function UIManager:Draw()
	if self.currentScreen then
		self.currentScreen:draw()
	end
end
return UIManager
