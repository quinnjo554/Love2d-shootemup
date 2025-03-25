-- entities/levelModel.lua
local AssetManager = require("core.AssetManager")
local NextButton = require("entities.NextButton")
local StartButton = require("startButton")
local EventManager = require("core.EventManager")

local LevelModel = {}

-- Constructor
-- TODO: Level Content is the current Path witch is an array of levels
--       we should just grab the current path from the stateManager
--
function LevelModel:new(x, y, width, height, levelContent, transitionState, eventManager, stateManager)
	local instance = {
		-- Injected dependencies
		eventManager = eventManager,
		stateManager = stateManager,

		-- UI positioning (non-state data)
		x = x,
		y = y,
		width = width,
		height = height,
		imageX = x + 120,
		imageY = y + 100,

		-- Visual components (not state)
		borderAsset = AssetManager:new("sprites/ui/GameBorder.png", x, y, width, height),
		checkedButtons = {},
		uncheckedButtons = {},
		nextButton = nil,
		startBattleButton = nil,

		-- Styling properties (not state)
		backgroundColor = { 0.3, 0.3, 0.35, 0.7 },
		borderColor = { 0, 0, 0, 0.8 },
		shadowColor = { 0.2, 0.2, 0.25, 0.5 },

		-- Transition callback
		transitionState = transitionState,
	}
	setmetatable(instance, { __index = LevelModel })

	-- Initialize state in the StateManager
	stateManager:set("levelSelect.content", levelContent)
	stateManager:set("levelSelect.currentIndex", 1)

	-- Calculate and store image dimensions
	if levelContent and levelContent[1] and levelContent[1].previewImg then
		instance.stateManager:set("levelSelect.imageWidth", levelContent[1].previewImg:getWidth())
		instance.stateManager:set("levelSelect.imageHeight", levelContent[1].previewImg:getHeight())
	end

	-- Initialize buttons
	instance:initButtons()

	-- Setup button callbacks
	instance.startBattleButton.onClick = function()
		local levelContent = instance.stateManager:get("levelSelect.content")
		local currentIndex = instance.stateManager:get("levelSelect.currentIndex")

		-- Emit battle initiated event with current level
		local currentLevel = levelContent[currentIndex]
		instance.stateManager:set("run.currentLevel", currentLevel)
		--intaance.eventManager:emit(EventManager.Types.BATTLE_INITIATED)
		instance.eventManager:emit(EventManager.Types.BATTLE_INITIATED, levelContent[currentIndex])
		-- I think levelContent[currentIndex] is the current level
		-- We should just emit the BATTEL_INITIATED and update the state of the current level. not pass it as an argument
		--

		-- Call transition callback
		instance.transitionState()
	end

	return instance
end

-- Initialize Buttons
function LevelModel:initButtons()
	local levelContent = self.stateManager:get("levelSelect.content")
	local imageWidth = self.stateManager:get("levelSelect.imageWidth")

	-- Create level selection buttons
	local buttonSpacing = 50
	local startX = self.imageX + (imageWidth / 2.5) - (#levelContent * buttonSpacing / 2)

	for i, level in ipairs(levelContent) do
		local buttonX = startX + (i - 1) * buttonSpacing
		local buttonY = self.imageY + self.stateManager:get("levelSelect.imageHeight") * 0.8

		-- Create button assets
		table.insert(self.checkedButtons, AssetManager:new("sprites/ui/FilledSprite.png", buttonX, buttonY, 30, 30))
		table.insert(self.uncheckedButtons, AssetManager:new("sprites/ui/UnfilledButton.png", buttonX, buttonY, 30, 30))
	end

	-- Initialize navigation buttons
	self.nextButton = NextButton:new(self.imageX + (imageWidth / 2), self.imageY + self.imageY, 50, 50, function()
		-- Update the current level index through state
		local levelContent = self.stateManager:get("levelSelect.content")
		local currentIndex = self.stateManager:get("levelSelect.currentIndex")
		local newIndex = (currentIndex % #levelContent) + 1
		self.stateManager:set("levelSelect.currentIndex", newIndex)
	end)

	self.startBattleButton = StartButton:new(900, 800)
end

-- Handle Mouse Press Events
function LevelModel:mousepressed(x, y, button)
	-- Handle start button press
	self.startBattleButton:handleMousePress(x, y, button)

	-- Handle next button press
	if self.nextButton and self.nextButton:mousepressed(x, y, button) then
		return
	end

	-- Handle level selection buttons
	local levelContent = self.stateManager:get("levelSelect.content")
	local imageWidth = self.stateManager:get("levelSelect.imageWidth")

	local buttonSpacing = 50
	local startX = self.imageX + (imageWidth / 2) - (#levelContent * buttonSpacing / 2)

	for i, _ in ipairs(levelContent) do
		local buttonX = startX + (i - 1) * buttonSpacing
		local buttonY = self.imageY + self.stateManager:get("levelSelect.imageHeight") * 0.8

		if x >= buttonX and x <= buttonX + 30 and y >= buttonY and y <= buttonY + 30 then
			-- Update state when a level button is clicked
			self.stateManager:set("levelSelect.currentIndex", i)
			return
		end
	end
end

-- Update
function LevelModel:update(dt)
	local mouse_x, mouse_y = love.mouse.getPosition()

	-- Update UI components
	if self.nextButton then
		self.nextButton:update(dt)
	end

	self.startBattleButton:update(mouse_x, mouse_y)
end

-- Draw
function LevelModel:draw()
	self:drawLevelPreview()
	self:drawButtons()

	if self.nextButton then
		self.nextButton:draw()
	end

	self.startBattleButton:draw()
end

-- Draw Current Level Preview
function LevelModel:drawLevelPreview()
	-- Get current state
	local levelContent = self.stateManager:get("levelSelect.content")
	local currentIndex = self.stateManager:get("levelSelect.currentIndex")
	local imageWidth = self.stateManager:get("levelSelect.imageWidth")
	local imageHeight = self.stateManager:get("levelSelect.imageHeight")

	-- Get current level from state
	local currentLevel = levelContent[currentIndex]

	-- Calculate scaled dimensions
	local scaledWidth = imageWidth * 0.8
	local scaledHeight = imageHeight * 0.8

	-- Create asset for current level preview
	local levelAsset = AssetManager:new(currentLevel.previewPath, self.imageX, self.imageY, scaledWidth, scaledHeight)

	-- Draw border and level preview
	self.borderAsset:draw()
	levelAsset:draw()

	-- Draw border
	love.graphics.setColor(self.borderColor)
	love.graphics.setLineWidth(10)
	love.graphics.rectangle("line", self.imageX, self.imageY, scaledWidth, scaledHeight)
	love.graphics.setColor(1, 1, 1, 1)
end

-- Draw Buttons
function LevelModel:drawButtons()
	-- Draw unchecked buttons
	for i, button in ipairs(self.uncheckedButtons) do
		button:draw()
	end

	-- Draw the checked button for the current index
	local currentIndex = self.stateManager:get("levelSelect.currentIndex")
	self.checkedButtons[currentIndex]:draw()
end

return LevelModel
