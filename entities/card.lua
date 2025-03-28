local love = require("love")
Card = {}

function Card:new(imagePath, x, y)
	local object = {
		x = x,
		y = y,
		angle = 0,
		speed = 1,
		maxSpeed = 5,
		acceleration = 0.1,
		width = 40,
		height = 40,
		imagePath = imagePath,
		image = nil,
		power = 100,
		isDragging = false,
		isClicked = false,
		isServed = false, -- Add this flag to track if the card is served
		isSelected = false, -- Add this flag to track if the card is served
		offsetX = 0,
		offsetY = 0,
	}
	setmetatable(object, { __index = Card })
	object:LoadImage(imagePath)

	return object
end

function Card:LoadImage(imagePath)
	self.image = love.graphics.newImage(imagePath)
	self.width = self.image:getWidth()
	self.height = self.image:getHeight()
end

function Card:move(dx, dy)
	self.x = self.x + dx * self.speed
end

function Card:drag(x, y, button)
	if button == 1 then
		if x > self.x and x <= self.x + self.width and y > self.y and y <= self.y + self.height then
			self.isDragging = true
			self.offsetX = x - self.x
			self.offsetY = y - self.y
		end
	end
end

function Card:click(x, y, button)
	if button == 1 then
		if x > self.x and x <= self.x + self.width and y > self.y and y <= self.y + self.height then
			self.isClicked = true
			self.isSelected = not self.isSelected
		end
	end
end

function Card:drop(button)
	if button == 1 then
		self.isDragging = false
	end
end

function Card:handleMouse(x, y, button, isPressed)
	if isPressed then
		-- Handle dragging
		if button == 1 and not self.isDragging then
			if x > self.x and x <= self.x + self.width and y > self.y and y <= self.y + self.height then
				self.isDragging = true
				self.offsetX = x - self.x
				self.offsetY = y - self.y
			end
		end

		-- Handle clicking and selection
		if button == 1 then
			if x > self.x and x <= self.x + self.width and y > self.y and y <= self.y + self.height then
				self.isClicked = true
				self.isSelected = not self.isSelected
			end
		end
	else
		-- Handle dropping
		if button == 1 then
			self.isDragging = false
		end
	end
end

function Card:update(dt)
	if self.isDragging then
		local mouseX, mouseY = love.mouse.getPosition()
		self.x = mouseX - self.offsetX
		self.y = mouseY - self.offsetY
	end

	if self.isClicked then
		if self.isSelected then
			self.y = self.y - 30
		else
			self.y = self.y + 30
		end
		self.isClicked = false
	end
end

function Card:draw()
	love.graphics.draw(self.image, self.x, self.y)
end
return Card
