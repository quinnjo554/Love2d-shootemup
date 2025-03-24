-- EnemyFormation.lua
local love = require("love")
local Enemy = require("entities.Enemy")
local CONFIG = require("utils.config")
EnemyFormation = {}

EnemyFormation.__index = EnemyFormation
function EnemyFormation:new(formationConfig, level, startX, startY, player)
	local formation = {
		config = formationConfig,
		enemies = {},
		offsetX = 0,
		offsetY = 0,
		speedX = formationConfig.movementPatterns[1]
				and CONFIG.MOVEMENT_PATTERNS[formationConfig.movementPatterns[1]].speedX
			or 100,
		speedY = 0,
		baseX = startX or love.graphics.getWidth() / 2,
		baseY = startY or 150,
		time = 0,
		currentPatternIndex = 1,
		patternSwitchTimer = 0,
		patternSwitchInterval = 5,
		player = player,
		level = level,
	}

	setmetatable(formation, { __index = EnemyFormation })
	formation:generateEnemies(level)
	return formation
end

function EnemyFormation:generateEnemies(level)
	self.enemies = {}
	local colCount = self.config.cols
	local rowCount = self.config.rows
	local totalWidth = (colCount - 1) * self.config.colSpacing
	local totalHeight = (rowCount - 1) * self.config.rowSpacing
	local startX = self.baseX - totalWidth / 2
	local startY = self.baseY - totalHeight / 2

	-- Track potential shooter positions
	local shooterPositions = {}

	-- Create all enemies first
	for row = 1, rowCount do
		for col = 1, colCount do
			local shouldAddEnemy = true
			if self.config.pattern then
				shouldAddEnemy = self.config.pattern[row] and self.config.pattern[row][col] == 1
			end

			if shouldAddEnemy then
				local x = startX + (col - 1) * self.config.colSpacing
				local y = startY + (row - 1) * self.config.rowSpacing
				local healthMultiplier = CONFIG.DIFFICULTY_SCALING.enemyHealthMultiplier(level)
				local enemy = Enemy:new(
					"Enemy " .. #self.enemies + 1,
					math.floor(10 * healthMultiplier),
					x,
					y,
					CONFIG.ASSETS.EMEMY_SPRITE,
					level
				)

				-- Store grid position for formation updates
				enemy.gridRow = row
				enemy.gridCol = col
				enemy.baseX = x
				enemy.baseY = y
				table.insert(self.enemies, enemy)

				-- Add to potential shooter positions
				table.insert(shooterPositions, #self.enemies)
			end
		end
	end

	local maxShooters = math.min(3 + (level - 1) * 2, #self.enemies)

	if level == 1 then
		maxShooters = math.min(3, #self.enemies)
	end

	-- shuffle the positions to randomize which enemies can shoot
	for i = #shooterPositions, 2, -1 do
		local j = math.random(i)
		shooterPositions[i], shooterPositions[j] = shooterPositions[j], shooterPositions[i]
	end

	-- assign shooting capabilities to selected enemies
	for i = 1, maxShooters do
		local enemyIndex = shooterPositions[i]
		local enemy = self.enemies[enemyIndex]
		if enemy then
			enemy.canShoot = true

			-- Increase shooting probability with level
			-- Level 1: 30% chance to shoot when cooldown is up
			-- Level 5+: 80% chance to shoot when cooldown is up
			enemy.shootProbability = math.min(0.3 + (level - 1) * 0.1, 0.8)

			if level >= 3 then
				-- All patterns available
				enemy.shotPattern =
					CONFIG.ENEMY_STATS.bullet_patterns[math.random(1, #CONFIG.ENEMY_STATS.bullet_patterns)]
			elseif level == 2 then
				-- Only straight and zigzag
				local patterns = { "straight", "zigzag" }
				enemy.shotPattern = patterns[math.random(1, 2)]
			else
				-- Only straight shots for level 1
				enemy.shotPattern = "straight"
			end

			-- Aiming at player more likely in higher levels
			enemy.aimsAtPlayer = (level >= 3) or (level >= 2 and math.random() > 0.5)

			-- Make cooldowns more variable in higher levels
			enemy.shootCooldown = 2.5 - (level * 0.2) + math.random() * 1.5
		end
	end
end

function EnemyFormation:update(dt, player)
	self.patternSwitchTimer = self.patternSwitchTimer + dt

	if self.patternSwitchTimer > self.patternSwitchInterval and #self.config.movementPatterns > 1 then
		self.currentPatternIndex = (self.currentPatternIndex % #self.config.movementPatterns) + 1
		self.patternSwitchTimer = 0
	end

	local patternName = self.config.movementPatterns[self.currentPatternIndex]
	local pattern = CONFIG.MOVEMENT_PATTERNS[patternName]

	if pattern and pattern.update then
		pattern.update(self, dt)
	end

	for _, enemy in ipairs(self.enemies) do
		if not enemy.isDead then
			enemy.x = enemy.baseX + self.offsetX
			enemy.y = enemy.baseY + self.offsetY
			enemy:update(dt, player)
		end
	end

	for i = #self.enemies, 1, -1 do
		if self.enemies[i].isDead then
			table.remove(self.enemies, i)
		end
	end
end

function EnemyFormation:draw()
	for _, enemy in ipairs(self.enemies) do
		if not enemy.isDead then
			enemy:draw()
		end
	end
end

function EnemyFormation:getEnemies()
	return self.enemies
end

return EnemyFormation
