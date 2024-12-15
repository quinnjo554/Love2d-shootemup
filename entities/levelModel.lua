local AssetManager = require("core.AssetManager")
local NextButton = require("entities.NextButton")
local StartButton = require("startButton")
local EventManager = require("core.EventManager")
-- TODO: Make a global file with Game constants, also make a animated sprite, and a sprite class, and a moveable interface

local LevelModel = {}

-- Constructor
function LevelModel:new(x, y, width, height, levelContent, transitionState, eventManager)
	local instance = {
		x = x,
		y = y,
		width = width,
		height = height,
		levelContent = levelContent,
		eventManager = eventManager,

		-- Calculated properties
		imageX = x + 120,
		imageY = y + 100,
		imageWidth = levelContent[1].previewImg:getWidth(),
		imageHeight = levelContent[1].previewImg:getHeight(),

		-- Styling properties
		backgroundColor = { 0.3, 0.3, 0.35, 0.7 },
		borderColor = { 0, 0, 0, 0.8 },
		shadowColor = { 0.2, 0.2, 0.25, 0.5 },

		-- Assets and buttons
		borderAsset = AssetManager:new("sprites/ui/GameBorder.png", x, y, width, height),
		checkedButtons = {},
		uncheckedButtons = {},
		nextButton = nil,
		startBattleButton = nil,

		-- State
		currentLevelIndex = 1,
	}
	setmetatable(instance, { __index = LevelModel })

	instance:initButtons()

	instance.startBattleButton.onClick = function()
		-- this emmits
		--set level
		instance.eventManager:emit(
			EventManager.Types.BATTLE_INITIATED,
			instance.levelContent[instance.currentLevelIndex]
		)
		transitionState()
	end

	return instance
end

-- Initialize Buttons
function LevelModel:initButtons()
	local buttonSpacing = 50
	local startX = self.imageX + (self.imageWidth / 2.5) - (#self.levelContent * buttonSpacing / 2)

	for i, level in ipairs(self.levelContent) do
		local buttonX = startX + (i - 1) * buttonSpacing
		local buttonY = self.imageY + self.imageHeight * 0.8

		-- Create button assets
		table.insert(self.checkedButtons, AssetManager:new("sprites/ui/FilledSprite.png", buttonX, buttonY, 30, 30))
		table.insert(self.uncheckedButtons, AssetManager:new("sprites/ui/UnfilledButton.png", buttonX, buttonY, 30, 30))
	end

	-- Initialize Next Button
	self.nextButton = NextButton:new(self.imageX + (self.imageWidth / 2), self.imageY + self.imageY, 50, 50, function()
		self.currentLevelIndex = (self.currentLevelIndex % #self.levelContent) + 1
	end)
	self.startBattleButton = StartButton:new(900, 800)
end

-- Handle Mouse Press Events
function LevelModel:mousepressed(x, y, button)
	self.startBattleButton:handleMousePress(x, y, button)
	if self.nextButton and self.nextButton:mousepressed(x, y, button) then
		return
	end

	local buttonSpacing = 50
	local startX = self.imageX + (self.imageWidth / 2) - (#self.levelContent * buttonSpacing / 2)

	for i, _ in ipairs(self.levelContent) do
		local buttonX = startX + (i - 1) * buttonSpacing
		local buttonY = self.imageY + self.imageHeight * 0.8

		if x >= buttonX and x <= buttonX + 30 and y >= buttonY and y <= buttonY + 30 then
			self.currentLevelIndex = i
			return
		end
	end
end

-- Update
function LevelModel:update(dt)
	local mouse_x, mouse_y = love.mouse.getPosition()
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
	local currentLevel = self.levelContent[self.currentLevelIndex]
	local scaledWidth = currentLevel.previewImg:getWidth() * 0.8
	local scaledHeight = currentLevel.previewImg:getHeight() * 0.8

	local levelAsset = AssetManager:new(currentLevel.previewPath, self.imageX, self.imageY, scaledWidth, scaledHeight)

	self.borderAsset:draw()
	levelAsset:draw()

	love.graphics.setColor(self.borderColor)
	love.graphics.setLineWidth(10)
	love.graphics.rectangle("line", self.imageX, self.imageY, scaledWidth, scaledHeight)
	love.graphics.setColor(1, 1, 1, 1)
end

-- Draw Buttons
function LevelModel:drawButtons()
	for i, button in ipairs(self.uncheckedButtons) do
		button:draw()
	end

	self.checkedButtons[self.currentLevelIndex]:draw()
end

return LevelModel
