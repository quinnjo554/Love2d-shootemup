local love = require("love")
local AssetManager = require("core.AssetManager")
local StartButton = require("StartButton")
local SpriteAnimation = require("ui.SpriteAnimation")
local CreateCommonBackgrounds = require("utils.sharedBackgrounds.sharedBackgrounds")
local CutsceneSprite = require("ui.AnimatedSprite")
local EventManager = require("core.EventManager")
local LevelModel = require("entities.levelModel")
local shallowcopy = require("utils.copyTable")

-- Constants
local SCREEN_CONSTANTS = {
	MODEL_WIDTH = 700,
	MODEL_HEIGHT = 700,
	CUTSCENE_CAT = {
		INITIAL_X = -240,
		INITIAL_Y = 935,
		TARGET_OFFSET_X = -96,
		SPRITE_SHEET = "sprites/ui/forest/CatSprite-Sheet.png",
		FRAME_WIDTH = 96,
		FRAME_HEIGHT = 96,
	},
	CUTSCENE_PLAYER = {
		INITIAL_X = -150,
		INITIAL_Y = 900,
		SPRITE_SHEET = "sprites/ui/Player-Sheet-export.png",
		FRAME_WIDTH = 128,
		FRAME_HEIGHT = 128,
	},
}

-- LevelSelectUI Class
local LevelSelectUI = {}

-- Constructor
function LevelSelectUI:new(eventManager, backgrounds)
	local screenWidth = love.graphics.getWidth() -- make global
	local screenHeight = love.graphics.getHeight()

	local object = {
		eventManager = eventManager,
		backgrounds = shallowcopy(backgrounds),
		levels = nil,
		levelSelectModel = nil,
		audio = nil,
		catCutsceneSprite = self:createCutsceneSprite(
			SCREEN_CONSTANTS.CUTSCENE_CAT,
			screenWidth / 2 + SCREEN_CONSTANTS.CUTSCENE_CAT.TARGET_OFFSET_X,
			SCREEN_CONSTANTS.CUTSCENE_CAT.INITIAL_Y
		),
		playerCutsceneSprite = self:createCutsceneSprite(
			SCREEN_CONSTANTS.CUTSCENE_PLAYER,
			screenWidth / 2,
			SCREEN_CONSTANTS.CUTSCENE_PLAYER.INITIAL_Y
		),
	}

	setmetatable(object, { __index = LevelSelectUI })

	object:initializeAudio()
	object:initializeCutsceneSprites()
	object:setupLevelModel()

	return object
end

function LevelSelectUI:setupLevelModel()
	self:_setupLevelModelEventHandler()
	self.eventManager:emit(EventManager.Types.REQUEST_CURRENT_RUN_PATH)
end

function LevelSelectUI:_setupLevelModelEventHandler()
	self.eventManager:on(EventManager.Types.CURRENT_RUN_PATH_RESPONSE, function(pathData)
		self.levels = pathData.currentPath
		self:_createLevelModel()
	end)
end

function LevelSelectUI:_createLevelModel()
	local screenWidth = love.graphics.getWidth()
	local screenHeight = love.graphics.getHeight()

	self.levelSelectModel = LevelModel:new(
		(screenWidth / 2) - SCREEN_CONSTANTS.MODEL_WIDTH / 2,
		(screenHeight / 2) - SCREEN_CONSTANTS.MODEL_HEIGHT / 2,
		SCREEN_CONSTANTS.MODEL_WIDTH,
		SCREEN_CONSTANTS.MODEL_HEIGHT,
		self.levels,
		function()
			self.eventManager:emit(EventManager.Types.STATE_CHANGED, "BATTLE")
		end,
		self.eventManager
	)
end

-- Helper method to create cutscene sprites with consistent configuration
function LevelSelectUI:createCutsceneSprite(constants, targetX, initialY)
	return CutsceneSprite:new({
		x = constants.INITIAL_X,
		y = initialY,
		speed = 4,
		targetX = targetX,
		targetY = initialY,
		spriteSheet = constants.SPRITE_SHEET,
		spriteFrames = 7,
		frameWidth = constants.FRAME_WIDTH,
		frameHeight = constants.FRAME_HEIGHT,
		spriteScale = 1,
	})
end

-- Initialize audio with better volume management
function LevelSelectUI:initializeAudio()
	self.audio = {
		backgroundMusic = love.audio.newSource("audio/main_menu/main_theme.mp3", "stream"),
	}
	self.audio.backgroundMusic:setLooping(true)
	self.audio.backgroundMusic:setVolume(0.5) -- More reasonable default volume
	self.audio.backgroundMusic:play()
end

-- Start cutscene sprites
function LevelSelectUI:initializeCutsceneSprites()
	self.playerCutsceneSprite:startCutscene()
	self.catCutsceneSprite:startCutscene()
end

-- Update method with improved readability
function LevelSelectUI:update(dt)
	-- Update backgrounds
	for _, background in ipairs(self.backgrounds) do
		background:update(dt)
	end

	-- Get mouse position
	local mouse_x, mouse_y = love.mouse.getPosition()

	-- Update cutscene sprites
	self.playerCutsceneSprite:update(dt)
	self.catCutsceneSprite:update(dt)

	-- Update level select model if exists
	if self.levelSelectModel then
		self.levelSelectModel:update(dt, mouse_x, mouse_y)
	end
end

-- Draw method with consistent naming
function LevelSelectUI:draw()
	-- Draw backgrounds
	for _, background in ipairs(self.backgrounds) do
		background:draw()
	end

	-- Draw cutscene sprites
	self.playerCutsceneSprite:draw()
	self.catCutsceneSprite:draw()

	-- Draw level select model if exists
	if self.levelSelectModel then
		self.levelSelectModel:draw()
	end
end

-- Mouse press handler
function LevelSelectUI:handleMousePress(x, y, button)
	if self.levelSelectModel then
		self.levelSelectModel:mousepressed(x, y, button)
	end
end

return LevelSelectUI
