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

function Player:new(name, stateManager)
	local player = {
		stateManager = stateManager,
		sprite = nil,
		healthBar = nil,
		name = name,
		bullets = {}, -- Keep bullets in instance for easier updates
	}

	setmetatable(player, self)

	-- Initialize sprite
	player.sprite = Sprite:new(
		CONFIG.ASSETS.SHIP_SPRITE,
		player.stateManager:get("player.width"),
		player.stateManager:get("player.height")
	)
	player.sprite:createAnimation("idle", 3, 2)
	player.sprite:createAnimation("left", 1, 4)
	player.sprite:createAnimation("right", 2, 4)
	player.sprite:setAnimation("idle")

	-- Initialize health bar (using values from state)
	local barWidth = 300
	player.healthBar = HealthBar:new(
		CONFIG.SCREEN_WIDTH,
		(CONFIG.SCREEN_HEIGHT * 1.5) + 50,
		(CONFIG.SCREEN_WIDTH - barWidth) / 2,
		10,
		player.stateManager:get("player.health"),
		player.stateManager:get("player.maxHealth")
	)

	-- Subscribe to player health changes
	player.stateManager:subscribe("player.health", function(newHealth)
		player.healthBar:update(newHealth)
	end)

	return player
end
function Player:levelUp()
	local level = self.stateManager:get("player.level") or 1
	level = level + 1
	self.stateManager:set("player.level", level)

	-- Increase base stats on level up
	local maxHealth = self.stateManager:get("player.maxHealth")
	self.stateManager:set("player.maxHealth", maxHealth + 10)

	-- Potentially unlock new features
	if level % 5 == 0 then
		self:unlockNewFeature()
	end
end

function Player:checkBoundaryCollision(dx, dy, windowWidth, windowHeight)
	local x = self.stateManager:get("player.x")
	print(x)
	local y = self.stateManager:get("player.y")
	print(y)
	local width = self.stateManager:get("player.width")
	local height = self.stateManager:get("player.height")

	local nextX = x + dx
	local nextY = y + dy

	-- Check window boundaries
	if nextX < 0 then
		nextX = 0
	elseif nextX + width > windowWidth then
		nextX = windowWidth - width
	end

	if nextY < 0 then
		nextY = 0
	elseif nextY + height > windowHeight then
		nextY = windowHeight - height
	end

	return nextX, nextY
end

function Player:takeDamage(damage)
	local health = self.stateManager:get("player.health")
	health = health - damage
	self.stateManager:set("player.health", health)

	if health <= 0 then
		self.stateManager:set("player.isDead", true)
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
							object:takeDamage(self.stateManager:get("player.damage"))
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

	self.stateManager:set("player.bullets", self.bullets)
end

function Player:checkObjectCollision(object)
	local x = self.stateManager:get("player.x")
	local y = self.stateManager:get("player.y")
	local width = self.stateManager:get("player.width")
	local height = self.stateManager:get("player.height")

	-- Rectangle collision detection (AABB)
	return x < object.x + object.width
		and x + width > object.x
		and y < object.y + object.height
		and y + height > object.y
end

function Player:update(dt, gameObjects)
	-- Update health bar
	self.healthBar:update(self.stateManager:get("player.health"))

	-- Move the player
	self:move(dt)

	-- Set player direction based on movement
	self:setPlayerDirection(dt)

	-- Handle shooting
	self:handleShoot()

	-- Update bullets
	self:updateBullets(dt, gameObjects)

	-- Handle object collisions
	self:handleObjectCollision(gameObjects)

	-- Update sprite animation
	self.sprite:setAnimation(self.stateManager:get("player.direction") or "idle")
	self.sprite:update(dt)
end

function Player:move(dt)
	local dx, dy = 0, 0
	local speed = self.stateManager:get("player.speed")

	-- Get input
	if love.keyboard.isDown("w") then
		dy = dy - speed * dt
	end
	if love.keyboard.isDown("s") then
		dy = dy + speed * dt
	end
	if love.keyboard.isDown("a") then
		dx = dx - speed * dt
	end
	if love.keyboard.isDown("d") then
		dx = dx + speed * dt
	end

	-- Check and resolve boundary collisions
	local windowWidth = love.graphics.getWidth()
	local windowHeight = love.graphics.getHeight()
	local nextX, nextY = self:checkBoundaryCollision(dx, dy, windowWidth, windowHeight)

	-- Update position in state
	self.stateManager:set("player.x", nextX)
	self.stateManager:set("player.y", nextY)
end

function Player:shoot()
	local currentTime = love.timer.getTime()
	local lastShootTime = self.stateManager:get("player.lastShootTime")
	local shootCooldown = self.stateManager:get("player.shootCooldown")

	if currentTime - lastShootTime >= shootCooldown then
		-- Get player position from state
		local x = self.stateManager:get("player.x")
		local y = self.stateManager:get("player.y")
		local width = self.stateManager:get("player.width")
		local height = self.stateManager:get("player.height")

		-- Create bullet from center of player
		local bulletX = x + width / 2
		local bulletY = y + height / 4

		local newBullet = Bullet:new(bulletX, bulletY, CONFIG.PLAYER_STATS.bullet_speed)
		table.insert(self.bullets, newBullet)

		-- Update last shoot time in state
		self.stateManager:set("player.lastShootTime", currentTime)
	end
end

function Player:setPlayerDirection(dt)
	local direction = self.stateManager:get("player.direction")
	if love.keyboard.isDown("a") then
		direction = "left"
	elseif love.keyboard.isDown("d") then
		direction = "right"
	else
		direction = "idle"
	end

	-- Set the current animation based on direction
	self.sprite:setAnimation(self.direction)
	self.sprite:update(dt)
	self.stateManager:set("player.direction", direction)
end

function Player:draw()
	local x = self.stateManager:get("player.x")
	local y = self.stateManager:get("player.y")

	self.sprite:draw(x, y)
	self.healthBar:draw()

	-- Draw bullets
	for _, bullet in ipairs(self.bullets) do
		bullet:draw()
	end
end

function Player:addExperience(amount)
	local experience = self.stateManager:get("player.experience") or 0
	local level = self.stateManager:get("player.level") or 1

	experience = experience + amount
	self.stateManager:set("player.experience", experience)

	-- Check if player can level up
	local experienceThreshold = level * 100
	if experience >= experienceThreshold then
		self:levelUp()
		experience = experience - experienceThreshold
		self.stateManager:set("player.experience", experience)
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

function Player:getCollisionRect()
	return {
		x = self.stateManager:get("player.x"),
		y = self.stateManager:get("player.y"),
		width = self.stateManager:get("player.width"),
		height = self.stateManager:get("player.height"),
	}
end

function Player:handleShoot()
	if love.keyboard.isDown("return") then
		self:shoot()
	end
end

return Player
