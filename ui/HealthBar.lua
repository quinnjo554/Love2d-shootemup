local HealthBar = {}

HealthBar.__index = HealthBar
function HealthBar:new(x, y, width, height, maxHealth, currentHealth)
	local object = {
		x = x,
		y = y,
		width = width,
		height = height,
		maxHealth = maxHealth,
		currentHealth = currentHealth,
	}
	setmetatable(object, { __index = HealthBar })
	return object
end

function HealthBar:draw()
	-- Draw the background of the health bar
	love.graphics.setColor(0.5, 0.5, 0.5) -- Gray color for the background
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	-- Calculate the width of the health portion
	local healthWidth = (self.currentHealth / self.maxHealth) * self.width

	-- Draw the health portion of the bar
	love.graphics.setColor(0, 1, 0) -- Green color for health
	love.graphics.rectangle("fill", self.x, self.y, healthWidth, self.height)

	-- Reset color to white
	love.graphics.setColor(1, 1, 1)
end

function HealthBar:update(currentHealth)
	self.currentHealth = currentHealth
end

return HealthBar
