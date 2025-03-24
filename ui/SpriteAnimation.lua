--DEPRICATED USE SPRITE
local love = require("love")
local SpriteAnimation = {}

function SpriteAnimation:new(spriteSheetPath, frameWidth, frameHeight, fps)
	local animation = {
		spriteSheet = love.graphics.newImage(spriteSheetPath),
		frameWidth = frameWidth,
		frameHeight = frameHeight,
		frames = {},
		currentFrame = 1,
		timer = 0,
		fps = fps or 10, -- Default to 10 frames per second
	}

	-- Calculate how many frames are in the sheet
	local sheetWidth = animation.spriteSheet:getWidth()
	local sheetHeight = animation.spriteSheet:getHeight()
	local framesX = math.floor(sheetWidth / frameWidth)
	local framesY = math.floor(sheetHeight / frameHeight)

	-- Create quads for each frame
	for y = 0, framesY - 1 do
		for x = 0, framesX - 1 do
			local quad = love.graphics.newQuad(
				x * frameWidth,
				y * frameHeight, -- X and Y position in the sprite sheet
				frameWidth,
				frameHeight, -- Width and height of each frame
				sheetWidth,
				sheetHeight -- Total sprite sheet dimensions
			)
			table.insert(animation.frames, quad)
		end
	end

	setmetatable(animation, self)
	self.__index = self
	return animation
end

function SpriteAnimation:update(dt)
	-- Update animation timer
	self.timer = self.timer + dt

	-- Change frame based on fps
	if self.timer > (1 / self.fps) then
		-- Move to next frame
		self.currentFrame = self.currentFrame + 1

		-- Reset to first frame if we've gone past the last frame
		if self.currentFrame > #self.frames then
			self.currentFrame = 1
		end

		-- Reset timer
		self.timer = 0
	end
end

function SpriteAnimation:draw(x, y, scale)
	scale = scale or 1
	love.graphics.draw(
		self.spriteSheet, -- The sprite sheet image
		self.frames[self.currentFrame] or 1, -- Current frame quad
		x,
		y, -- Position to draw
		0, -- rotation
		scale,
		scale -- x and y scale
	)
end

return SpriteAnimation
