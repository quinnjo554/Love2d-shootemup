local love = require("love")
local Sprite = require("ui.Sprite")
local Bullet = require("entities.Bullet")
local CONFIG = require("utils.config")

Enemy = {}

function Enemy:new(name, health, x, y, spritePath, level)
	local object = {
		name = name,
		attack = CONFIG.ENEMY_STATS.attack,
		defense = CONFIG.ENEMY_STATS.defense,
		health = health,
		x = x,
		y = y,
		type = "enemy",
		width = 128,
		height = 128,
		speed = CONFIG.ENEMY_STATS.speed,
		shotSpeed = CONFIG.ENEMY_STATS.bullet_speed,
		isDead = false,
		sprite = nil,
		isExploding = false,
		explosionTimer = 100,
		level = level,

		bullets = {},
		bulletTimer = 0,
		bulletFrequency = 1,
		canShoot = true,
		aimsAtPlayer = true,
		shotPattern = CONFIG.ENEMY_STATS.bullet_patterns[math.random(1, #CONFIG.ENEMY_STATS.bullet_patterns)],
		--todo: update this with level
		shootProbability = CONFIG.ENEMY_STATS.shoot_probability,

		burstCount = 0,
		burstMax = 3,
		burstDelay = 0.2,
		shotAngle = 0, -- For spread shots
		telegraphTime = 0.7, -- For telegraph effect
		lastShootTime = love.timer.getTime(),
		shootCooldown = 6,
		currentTime = 0,
	}
	setmetatable(object, { __index = Enemy })
	object.sprite = Sprite:new(spritePath or CONFIG.ASSETS.SHIP_SPRITE, 128, 128)
	object.sprite:createAnimation("idle", 3, 2)
	object.sprite:setAnimation("idle")
	return object
end

function Enemy:draw()
	if self.sprite then
		self.sprite:draw(self.x, self.y)
	end
	for _, bullet in ipairs(self.bullets) do
		bullet:draw()
	end
end

function Enemy:update(dt, player)
	self:updateBullets(dt, player)
	if self.isExploding then
		self.sprite:update(dt)
		self.explosionTimer = self.explosionTimer - dt
		self.canShoot = false
	end

	if self.canShoot then
		self.currentTime = love.timer.getTime()

		if self.currentTime - self.lastShootTime >= self.shootCooldown then
			if math.random() < self.shootProbability then
				self:performShot(player)
			end
			self.lastShootTime = self.currentTime
		end
	end

	if self.explosionTimer <= 0 then
		self.isDead = true
	end
	self.sprite:update(dt)
end

function Enemy:takeDamage(damage)
	self.health = self.health - damage
	if self.health <= 0 then
		self.isExploding = true
		self.sprite = Sprite:new(CONFIG.ASSETS.EXPLOSION_SPRITE, 92, 92)
		self.sprite:createAnimation("explode", 1, 3)
		self.sprite:setAnimation("explode")
		self.explosionTimer = 3 * 0.1 -- 3 frames at 10 fps
	end
end

function Enemy:performShot(player)
	if self.shotPattern == "straight" then
		if self.aimsAtPlayer and player then
			local dx = player.x - self.x
			local dy = player.y - self.y
			self.shotAngle = math.atan2(dy, dx)
		else
			self.shotAngle = math.pi / 2
		end
		self:shootSingle(self.shotAngle)
	elseif self.shotPattern == "spread" then
		-- Spread pattern (multiple angles)
		local baseAngle = math.pi / 2 -- Downward
		if self.aimsAtPlayer and player then
			local dx = player.x - self.x
			local dy = player.y - self.y
			baseAngle = math.atan2(dy, dx)
		end

		-- 3-way spread
		self:shootSingle(baseAngle - 0.3)
		self:shootSingle(baseAngle)
		self:shootSingle(baseAngle + 0.3)
	elseif self.shotPattern == "zigzag" then
		-- Zigzag pattern
		self.shotAngle = math.pi / 2 + math.sin(self.currentTime * 5) * 0.3
		self:shootSingle(self.shotAngle)
	end
end

function Enemy:shootSingle(angle)
	local bulletX = self.x + self.width / 2
	local bulletY = self.y + self.height / 2

	local bullet = Bullet:new(bulletX, bulletY, self.shotSpeed, angle, "enemy")
	table.insert(self.bullets, bullet)
end

function Enemy:updateBullets(dt, player)
	for i = #self.bullets, 1, -1 do
		local bullet = self.bullets[i]
		bullet:update(dt)

		if player then
			if bullet:checkCollision(player) then
				if player.takeDamage then
					player:takeDamage(self.attack)
				end
				bullet.isDead = true
			end
		end

		-- Remove bullets that are out of bounds or hit something
		if
			bullet.isDead
			or bullet.x < -50
			or bullet.x > love.graphics.getWidth() + 50
			or bullet.y < -50
			or bullet.y > love.graphics.getHeight() + 50
		then
			table.remove(self.bullets, i)
		end
	end
end

return Enemy
