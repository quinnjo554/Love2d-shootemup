local CONFIG = require("utils.config")
local Sprite = require("ui.Sprite")
local Bullet = {}
Bullet.__index = Bullet

function Bullet:new(x, y, speed, angle, source)
	local bullet = {
		sprite = nil,
		x = x,
		y = y,
		width = source == "enemy" and 6 or 8, -- Enemy bullets smaller
		height = source == "enemy" and 6 or 8,
		speed = speed or 300,
		angle = angle or math.pi / 2, -- Default downward for enemies, upward for player
		isDead = false,
		source = source or "player", -- "player" or "enemy"
		color = source == "enemy" and { 1, 0.3, 0.3 } or { 0.3, 0.7, 1 }, -- Red for enemies, blue for player
	}
	setmetatable(bullet, self)

	bullet.sprite = Sprite:new(CONFIG.ASSETS.SHIP_SPRITE, bullet.width, bullet.height)

	return bullet
end

function Bullet:update(dt)
	-- Update position based on direction
	if self.source == "player" then
		self.y = self.y - self.speed * dt
	else
		self.x = self.x + math.cos(self.angle) * self.speed * dt
		self.y = self.y + math.sin(self.angle) * self.speed * dt
	end
	-- Check if bullet is off screen
	if self.x < 0 or self.x > love.graphics.getWidth() or self.y < 0 or self.y > love.graphics.getHeight() then
		self.isDead = true
	end
end

function Bullet:checkCollision(object)
	return self.x < object.x + object.width
		and self.x + self.width > object.x
		and self.y < object.y + object.height
		and self.y + self.height > object.y
end

function Bullet:draw()
	love.graphics.setColor(1, 1, 0) -- Yellow bullet
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(1, 1, 1) -- Reset color
end

return Bullet
