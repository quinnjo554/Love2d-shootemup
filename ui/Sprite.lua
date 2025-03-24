local Sprite = {}
Sprite.__index = Sprite

function Sprite:new(imagePath, frameWidth, frameHeight)
	local sprite = {
		image = love.graphics.newImage(imagePath), -- Load the sprite sheet image
		frameWidth = frameWidth,
		frameHeight = frameHeight,
		animations = {}, -- Store animations
		currentAnimation = nil, -- The current animation to play
		currentFrame = 1, -- Active frame in the current animation
		currentTime = 0, -- Time tracker for animation frame update
		frameTime = 0.1, -- Time per frame
	}
	setmetatable(sprite, self)

	sprite.width = sprite.image:getWidth()
	sprite.height = sprite.image:getHeight()
	sprite:createAnimation("default", 1, 1) -- Just use first frame
	sprite:setAnimation("default")
	return sprite
end

function Sprite:createAnimation(name, row, numFrames)
	local quads = {}
	for i = 0, numFrames - 1 do
		table.insert(
			quads,
			love.graphics.newQuad(
				i * self.frameWidth,
				(row - 1) * self.frameHeight,
				self.frameWidth,
				self.frameHeight,
				self.width,
				self.height
			)
		)
	end
	self.animations[name] = quads
end

-- Set the current animation
function Sprite:setAnimation(name)
	self.currentAnimation = self.animations[name]
	self.currentFrame = 1 -- Reset to the first frame
end

-- Update the animation
function Sprite:update(dt)
	if not self.currentAnimation then
		return
	end

	self.currentTime = self.currentTime + dt
	if self.currentTime >= self.frameTime then
		self.currentTime = self.currentTime - self.frameTime
		self.currentFrame = self.currentFrame + 1

		-- Loop the animation
		if self.currentFrame > #self.currentAnimation then
			self.currentFrame = 1
		end
	end
end

-- Draw the sprite
function Sprite:draw(x, y)
	if self.currentAnimation then
		love.graphics.draw(self.image, self.currentAnimation[self.currentFrame], x, y)
	end
end

return Sprite
