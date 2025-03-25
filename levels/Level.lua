local CONFIG = require("utils.config")
local Level = {}
local EnemyFormation = require("entities.EnemyFormation")

function Level:new(name, previewPath, imgs, player, stateManager)
	local level = {
		stateManager = stateManager,
		previewImg = love.graphics.newImage(previewPath),
		previewPath = previewPath,
		paths = imgs,
		reward = "Reward: 1000",
		enemies = {},
		levelName = name,
		winCondition = "",
		perspective = { "3d", "isometric", "sidescroller" },
		formations = {}, -- Store all formations for this level
		difficultyLevel = 1,
		player = player,
	}

	setmetatable(level, { __index = Level })

	level:GenerateEnemies(level.difficultyLevel)

	return level
end

function Level:GenerateEnemies(roundNumber)
	-- Clear any existing enemies
	self.enemies = {}

	-- Determine available formations based on player progress
	local availableFormations = {}
	for _, formation in ipairs(CONFIG.ENEMY_FORMATIONS) do
		if formation.unlockLevel <= roundNumber then
			table.insert(availableFormations, formation)
		end
	end

	-- If no formations are available, use a fallback
	if #availableFormations == 0 then
		table.insert(availableFormations, CONFIG.ENEMY_FORMATIONS[1])
	end

	-- Select a random formation from available ones
	local selectedFormation = availableFormations[math.random(1, #availableFormations)]

	-- Create the formation manager
	local formation = EnemyFormation:new(
		selectedFormation,
		roundNumber,
		love.graphics.getWidth() / 2, -- Center X
		love.graphics.getHeight() / 4, -- Near top of screen
		self.player,
		self.stateManager
	)

	-- Store the formation and get all enemies
	table.insert(self.formations, formation)
	self.enemies = formation:getEnemies()

	print(
		"Generated "
			.. #self.enemies
			.. " enemies in "
			.. selectedFormation.name
			.. " formation for level "
			.. roundNumber
	)
end

function Level:update(dt)
	for _, formation in ipairs(self.formations) do
		formation:update(dt)
	end
end

function Level:draw()
	for _, formation in ipairs(self.formations) do
		formation:draw()
	end
end

return Level
