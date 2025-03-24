local love = require("love")

StartButton = {}

function StartButton:new(x, y, text, width, height)
	local object = {
		x = x or love.graphics.getWidth() - 250,
		y = y or love.graphics.getHeight() - 150,
		width = width or 200,
		height = height or 80,
		text = text or "Start",
		isHovered = false,
		isEnabled = true,
		onClick = nil,
	}
	setmetatable(object, { __index = StartButton })
	object:loadAudio()
	return object
end

function StartButton:loadAudio()
	self.audio = {
		hover_sound = love.audio.newSource("audio/main_menu/hover_sound.mp3", "stream"),
		click_sound = love.audio.newSource("audio/main_menu/start_click_sound.mp3", "stream"),
	}
end

function StartButton:setEnabled(value)
	self.isEnabled = value
end

function StartButton:handleMousePress(mouseX, mouseY, button)
	if button == 1 and self.isHovered then
		self.onClick() -- Trigger the click action
		self.audio.click_sound:play()
	end
end

function StartButton:update(mouseX, mouseY)
	-- Update hover state
	local isNowHovered = mouseX >= self.x
		and mouseX <= (self.x + self.width)
		and mouseY >= self.y
		and mouseY <= (self.y + self.height)

	if isNowHovered and not self.isHovered then
		self.audio.hover_sound:play()
	end

	self.isHovered = isNowHovered

	-- Optionally, update animations or effects
	if self.isHovered then
		self.color = { 0.8, 0.8, 1 } -- Highlighted color
	else
		self.color = { 1, 1, 1 } -- Default color
		self.audio.hover_sound:stop()
	end
end

function StartButton:draw()
	if not self.isEnabled then
		return
	end

	-- Retro color palette
	local baseColor = { 0.2, 0.2, 0.3, 1 } -- Deep navy blue
	local hoverColor = { 0.3, 0.3, 0.5, 1 } -- Slightly lighter navy
	local borderColor = { 0.8, 0.8, 0.9, 1 } -- Light grayish-white
	local shadowColor = { 0.1, 0.1, 0.2, 0.6 } -- Dark shadow

	-- Draw shadow for depth
	love.graphics.setColor(shadowColor)
	love.graphics.rectangle("fill", self.x + 4, self.y + 4, self.width, self.height, 8)

	-- Set button base color
	love.graphics.setColor(self.isHovered and hoverColor or baseColor)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 8)

	-- Draw border
	love.graphics.setColor(borderColor)
	love.graphics.setLineWidth(3)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 8)

	-- Beveled effect
	if self.isHovered then
		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.rectangle("line", self.x + 2, self.y + 2, self.width - 4, self.height - 4, 6)
	end

	-- Draw text
	local textColor = { 1, 1, 1, 1 }
	local textShadowColor = { 0, 0, 0, 0.4 }

	-- Text shadow for depth
	love.graphics.setColor(textShadowColor)
	love.graphics.printf(self.text, self.x + 2, self.y + self.height / 2 - 9, self.width, "center")

	-- Text
	love.graphics.setColor(textColor)
	love.graphics.printf(self.text, self.x, self.y + self.height / 2 - 10, self.width, "center")

	-- Reset color
	love.graphics.setColor(1, 1, 1, 1)
end

function StartButton:checkHover(x, y)
	self.isHovered = x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
	return self.isHovered
end

function StartButton:checkClick(x, y, button)
	if button ~= 1 or not self.isEnabled then
		return false
	end

	return x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height
end
return StartButton
