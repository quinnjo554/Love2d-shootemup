-- AssetManager.lua
local AssetManager = {}
function AssetManager:new(imagePath, x, y, width, height, speed)
	local manager = {
		image = nil,
		imagePath = imagePath,
		x = x,
		y = y,
		width = width,
		height = height,
		speed = speed or 0,
		scaleX = width / love.graphics.newImage(imagePath):getWidth(),
		scaleY = height / love.graphics.newImage(imagePath):getHeight(),
	}
	setmetatable(manager, self)
	self.__index = self
	return manager
end

function AssetManager:loadImage()
	if not self.image then
		self.image = love.graphics.newImage(self.imagePath)
		self.scaleX = self.width / self.image:getWidth()
		self.scaleY = self.height / self.image:getHeight()
	end
end

function AssetManager:update(dt)
	self:loadImage()
	-- Move the image by its speed
	self.x = self.x - self.speed * dt

	-- Reset position to the right side when the image moves off-screen
	if self.x + (self.image:getWidth() * self.scaleX) < 0 then
		self.x = love.graphics.getWidth()
	end
end

function AssetManager:draw(alpha)
	self:loadImage()
	if alpha == nil then
		alpha = 1
	end
	love.graphics.draw(
		self.image,
		self.x,
		self.y,
		0, -- rotation
		self.scaleX,
		self.scaleY
	)

	-- Draw a second image to create a seamless scrolling effect
	if self.speed > 0 then
		love.graphics.draw(
			self.image,
			self.x + (self.image:getWidth() * self.scaleX),
			self.y,
			0, -- rotation
			self.scaleX,
			self.scaleY
		)
	end
	love.graphics.setColor(1, 1, 1, alpha)
end

return AssetManager
