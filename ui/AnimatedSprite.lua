local love = require("love")
local SpriteAnimation = require("ui.SpriteAnimation")
local CutsceneSprite = {}

function CutsceneSprite:new(options)
	-- Default configuration
	local defaultConfig = {
		-- Starting position (off-screen)
		x = -100,
		y = love.graphics.getHeight() - 100,

		-- Movement parameters
		speed = 100, -- pixels per second
		targetX = love.graphics.getWidth() / 2,
		targetY = love.graphics.getHeight() / 2,

		-- Sprite animation details
		spriteSheet = "sprites/ui/Player-Sheet.png",
		frameWidth = 78, -- Add frame width explicitly
		frameHeight = 78, -- Add frame height explicitly
		spriteFrames = 0.1,
		spriteScale = 1,

		-- Movement states
		movementState = "offscreen", -- States: offscreen, moving, centered
	}

	-- Merge provided options with default configuration
	local config = {}
	for k, v in pairs(defaultConfig) do
		config[k] = options and options[k] ~= nil and options[k] or v
	end

	-- Create the sprite object
	local object = {
		x = config.x,
		y = config.y,
		speed = config.speed,
		targetX = config.targetX,
		targetY = config.targetY,
		movementState = config.movementState,
		spriteScale = config.spriteScale,

		-- Add smooth movement interpolation variables
		moveProgress = 0,
		moveDuration = 0,
	}

	-- Set metatable
	setmetatable(object, self)
	self.__index = self

	-- Initialize sprite animation with correct parameters
	object.pauSprite = SpriteAnimation:new(
		config.spriteSheet,
		config.frameWidth, -- Pass frame width
		config.frameHeight, -- Pass frame height
		config.spriteFrames
	)

	return object
end

-- Update sprite position and movement with smooth interpolation
function CutsceneSprite:update(dt)
	if self.movementState == "moving" then
		-- Calculate total movement distance
		local dx = self.targetX - self.x
		local dy = self.targetY - self.y
		local totalDistance = math.sqrt(dx * dx + dy * dy)

		-- Calculate movement duration based on distance and speed
		if self.moveDuration == 0 then
			self.moveDuration = totalDistance / self.speed
		end

		-- Update movement progress
		self.moveProgress = self.moveProgress + dt

		-- Use smooth interpolation (easing)
		local t = math.min(self.moveProgress / self.moveDuration, 1)
		-- Smooth step interpolation (smooths start and end)
		t = t * t * (3 - 2 * t)

		-- Interpolate position
		self.x = self.x + (self.targetX - self.x) * t
		self.y = self.y + (self.targetY - self.y) * t

		-- Check if movement is complete
		if t >= 1 then
			self.x = self.targetX
			self.y = self.targetY
			self.movementState = "centered"
			self.moveProgress = 0
			self.moveDuration = 0
		end

		-- Update sprite animation
		self.pauSprite:update(dt)
	end
end

-- Draw the sprite
function CutsceneSprite:draw()
	if self.pauSprite and (self.movementState == "moving" or self.movementState == "centered") then
		self.pauSprite:draw(self.x, self.y, self.spriteScale)
	end
end

-- Start the cutscene movement
function CutsceneSprite:startCutscene()
	if self.movementState == "offscreen" then
		self.movementState = "moving"
		self.moveProgress = 0
		self.moveDuration = 0
	end
end

-- Reset sprite to initial state
function CutsceneSprite:reset()
	self.x = -100
	self.y = love.graphics.getHeight() - 100
	self.movementState = "offscreen"
	self.moveProgress = 0
	self.moveDuration = 0
end

return CutsceneSprite
