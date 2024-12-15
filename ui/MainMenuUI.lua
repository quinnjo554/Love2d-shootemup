local love = require("love")
local AssetManager = require("core.AssetManager")
local StartButton = require("StartButton")
local SpriteAnimation = require("ui.SpriteAnimation")
local CreateCommonBackground = require("utils.sharedBackgrounds.sharedBackgrounds")
local EventManager = require("core.EventManager")
local CONFIG = require("utils.config")
local shallowcopy = require("utils.copyTable")
local MainMenuUI = {}

function MainMenuUI:new(eventManager, backgrounds)
	local object = {
		AssetManager = {},
		eventManager = eventManager,
		-- static background elements
		backgrounds = shallowcopy(backgrounds),
		-- load non static elements
		startButton = StartButton:new(CONFIG.SCREEN_WIDTH + 100, CONFIG.SCREEN_HEIGHT + CONFIG.SCREEN_HEIGHT / 4),
		-- audio
		audio = self:loadAudio(),
		logoAlpha = 0,
		buttonAlpha = 0,
	}

	setmetatable(object, { __index = MainMenuUI })

	table.insert(
		object.backgrounds,
		AssetManager:new(
			"sprites/ui/main_logo3.png",
			525,
			150,
			love.graphics.getWidth() / 2,
			love.graphics.getHeight() / 2,
			0
		)
	)

	object.startButton.onClick = function()
		-- Directly call the provided callback when button is clicked
		if eventManager then
			eventManager:emit(EventManager.Types.STATE_CHANGED, "LEVEL")
		end
	end
	return object
end

function MainMenuUI:loadAudio()
	self.audio = {
		backgroundMusic = love.audio.newSource("audio/main_menu/main_theme.mp3", "stream"),
	}

	self.audio.backgroundMusic:setLooping(true)
	self.audio.backgroundMusic:play()
end

-- move background ui elements
function MainMenuUI:update(dt)
	for _, background in ipairs(self.backgrounds) do
		background:update(dt)
	end

	local mouse_x, mouse_y = love.mouse.getPosition()
	self.startButton:update(mouse_x, mouse_y)
end

-- draw ui elemementrs
function MainMenuUI:draw(index)
	for i, background in ipairs(self.backgrounds) do
		background:draw()
	end
	-- Draw the start button
	self.startButton:draw()
	-- meed to draw start button isHovered
	--
	love.graphics.print("Start Button isHovered: " .. tostring(self.startButton.isHovered), 100, 160)
end
function MainMenuUI:handleMousePress(x, y, button)
	if self.startButton and self.startButton.handleMousePress then
		self.startButton:handleMousePress(x, y, button)
	end
end

return MainMenuUI
