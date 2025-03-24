local love = require("love")
local Card = require("entities.card")
Deck = {}

function Deck:new(x, y)
	local object = {
		x = x,
		y = y,
		width = 40,
		height = 40,
		image = nil,
		isServed = false,
		Cards = {},
	}

	setmetatable(object, { __index = Deck })
	object:fillDeck()
	object:shuffle()
	return object
end

function Deck:addCard(card)
	table.insert(self.Cards, card)
end

function Deck:fillDeck()
	for i = 1, 52 do
		RAND = love.math.random(1, 2)
		local imagePath = RAND == 1 and "sprites/cardImgs/firebolt1.png" or "sprites/cardImgs/redFireball.png"
		local card = Card:new(imagePath, self.x, self.y)
		self:addCard(card)
	end
end

function Deck:removeCard(card)
	for i, val in ipairs(self.Cards) do
		if val == card then
			table.remove(self.Cards, i)
		end
	end
end

function Deck:shuffle()
	for i = 1, #self.Cards do --#self.Cards is the length of the Cards table
		local j = love.math.random(1, #self.Cards)
		self.Cards[i], self.Cards[j] = self.Cards[j], self.Cards[i]
	end
end

function Deck:update(dt)
	for i, val in ipairs(self.Cards) do
		val:update(dt)
	end
end

function Deck:handleMouseInput(x, y)
	for i = 1, #self.Cards do
		self.Cards[i]:handleMouseInput()
	end
end

function Deck:ServeCards()
	-- take the first 5 cards from the deck and set there x and y to the 5 spots on the board
	local _, windowHeight = love.graphics.getDimensions()
	for i = 1, 5 do
		self.Cards[i].x = 240 + i * 200
		self.Cards[i].y = windowHeight + 220
		self.Cards[i].isServed = true
	end
end

function Deck:draw()
	for i, val in ipairs(self.Cards) do
		val:draw()
	end
end
return Deck
