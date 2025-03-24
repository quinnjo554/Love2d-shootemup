local love = require("love")
local CONFIG = require("utils.config")
-- entities/Player.lua
local HealthBar = require("ui.HealthBar")
local Sprite = require("ui.Sprite")
local Bullet = require("entities.bullet")
-- local RuneCollection = require "entities.RuneCollection"

--TODO: Make 3 different player classes 3d,iso,sidescroller then render the correct one in BattleUI

local Player = {}
Player.__index = Player

function Player:new(name)
	local localBarWidth = 300
	local player = {
		x = CONFIG.SCREEN_WIDTH + 100,
		y = CONFIG.SCREEN_HEIGHT * 1.5,
		speed = CONFIG.PLAYER_STATS.speed,
		width = 64,
		height = 96,
		direction = "idle",
		sprite = nil,
		shield = CONFIG.PLAYER_STATS.sheild,
		damage = CONFIG.PLAYER_STATS.damage,
		healthBar = nil,
		health = CONFIG.PLAYER_STATS.health,
		maxHealth = CONFIG.PLAYER_STATS.health,
		bullets = {},
		lastShootTime = 0,
		shootCooldown = CONFIG.PLAYER_STATS.shoot_cooldown,
		maxBullets = 30,
		barHeight = 30,
		barX = (CONFIG.SCREEN_WIDTH - localBarWidth) / 2,
		barY = 10,
	}

	setmetatable(player, self)

	player.sprite = Sprite:new(CONFIG.ASSETS.SHIP_SPRITE, player.width, player.height)
	player.sprite:createAnimation("idle", 3, 2) -- 1st row for idle animation, 4 frames
	player.sprite:createAnimation("left", 1, 4) -- 2nd row for left animation, 4 frames
	player.sprite:createAnimation("right", 2, 4) -- 3rd row for right animation, 4 frames
	player.sprite:setAnimation("idle")

	player.healthBar = HealthBar:new(
		CONFIG.SCREEN_WIDTH,
		(CONFIG.SCREEN_HEIGHT * 1.5) + 50,
		player.barX,
		player.barY,
		player.health,
		player.maxHealth
	)
	return player
end

function Player:levelUp()
	self.level = self.level + 1

	-- Increase base stats on level up
	--self.stats.maxHealth = self.stats.maxHealth + 10
	--self.stats.maxMana = self.stats.maxMana + 5

	-- Potentially unlock new deck slots or rune types
	if self.level % 5 == 0 then
		self:unlockNewFeature()
	end
end

function Player:checkBoundaryCollision(dx, dy, windowWidth, windowHeight)
	local nextX = self.x + dx
	local nextY = self.y + dy

	-- Check window boundaries
	if nextX < 0 then
		nextX = 0
	elseif nextX + self.width > windowWidth then
		nextX = windowWidth - self.width
	end

	if nextY < 0 then
		nextY = 0
	elseif nextY + self.height > windowHeight then
		nextY = windowHeight - self.height
	end

	return nextX, nextY
end

function Player:takeDamage(damage)
	self.health = self.health - damage
	if self.health <= 0 then
		self.isDead = true
		-- Emit event for player death
	end
end

function Player:updateBullets(dt, gameObjects)
	for i = #self.bullets, 1, -1 do
		local bullet = self.bullets[i]
		bullet:update(dt)

		-- Check collisions with game objects
		if gameObjects then
			for _, object in ipairs(gameObjects) do
				if bullet:checkCollision(object) then
					if object.type == "enemy" then
						if object.takeDamage then
							object:takeDamage(self.damage)
						end
						bullet.isDead = true
					elseif object.type == "solid" then
						bullet.isDead = true
					end
				end
			end
		end

		-- Remove dead bullets
		if bullet.isDead then
			table.remove(self.bullets, i)
		end
	end
end

function Player:checkObjectCollision(object)
	-- Rectangle collision detection (AABB)
	return self.x < object.x + object.width
		and self.x + self.width > object.x
		and self.y < object.y + object.height
		and self.y + self.height > object.y
end

function Player:update(dt, gameObjects)
	-- check collison
	-- check bounds
	self.healthBar:update(self.health)
	self:move(dt)
	self:setPlayerDirection(dt)

	self:handleShoot()
	self:updateBullets(dt, gameObjects)
	self:handleObjectCollision(gameObjects)

	self.sprite:setAnimation(self.direction)
	self.sprite:update(dt)
end

function Player:move(dt)
	local dx, dy = 0, 0 -- Initialize movement deltas

	if love.keyboard.isDown("w") then
		dy = dy - self.speed * dt -- Move up
	end
	if love.keyboard.isDown("s") then
		dy = dy + self.speed * dt -- Move down
	end
	if love.keyboard.isDown("a") then
		dx = dx - self.speed * dt -- Move left
	end
	if love.keyboard.isDown("d") then
		dx = dx + self.speed * dt -- Move right
	end

	-- Update position using combined deltas
	local windowWidth = love.graphics.getWidth()
	local windowHeight = love.graphics.getHeight()

	-- Check and resolve boundary collisions
	local nextX, nextY = self:checkBoundaryCollision(dx, dy, windowWidth, windowHeight)

	-- Update position
	self.x = nextX
	self.y = nextY

	-- Update sprite position
end

function Player:shoot()
	local currentTime = love.timer.getTime()

	if currentTime - self.lastShootTime >= self.shootCooldown then
		-- Create bullet from center of player
		local bulletX = self.x + self.width / 2
		local bulletY = self.y + self.height / 4

		local newBullet = Bullet:new(bulletX, bulletY, CONFIG.PLAYER_STATS.bullet_speed)
		table.insert(self.bullets, newBullet)
		self.lastShootTime = currentTime
	end
end

function Player:setPlayerDirection(dt)
	if love.keyboard.isDown("a") then
		self.direction = "left"
	elseif love.keyboard.isDown("d") then
		self.direction = "right"
	else
		self.direction = "idle"
	end

	-- Set the current animation based on direction
	self.sprite:setAnimation(self.direction)
	self.sprite:update(dt)
end

function Player:draw()
	self.sprite:draw(self.x, self.y)
	self.healthBar:draw()
	for _, bullet in ipairs(self.bullets) do
		bullet:draw()
	end
end

function Player:addExperience(amount)
	self.experience = self.experience + amount

	-- Check if player can level up
	local experienceThreshold = self.level * 100
	if self.experience >= experienceThreshold then
		self:levelUp()
		self.experience = self.experience - experienceThreshold
	end
end

function Player:unlockNewFeature()
	-- Example of unlocking new mechanics
	print("New feature unlocked at level " .. self.level)
end

function Player:handleObjectCollision(gameObjects)
	if gameObjects then
		for _, object in ipairs(gameObjects) do
			if self:checkObjectCollision(object) then
				if object.type == "enemy" then
				-- implement knockback
				elseif object.type == "collectible" and object.collect then
					object:collect()
				elseif object.type == "solid" then
					--
				end
			end
		end
	end
end

function Player:handleShoot()
	if love.keyboard.isDown("return") then
		self:shoot()
	end
end

return Player
