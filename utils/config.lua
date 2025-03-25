-- Config.lua
local Config = {}

-- Screen dimensions
Config.SCREEN_WIDTH = love.graphics.getWidth()
Config.SCREEN_HEIGHT = love.graphics.getHeight()

Config.DECK_SIZE = 52
Config.INITIAL_HAND_SIZE = 5

Config.PLAYER_STATS = {
	damage = 10,
	health = 10,
	shield = 2,
	speed = 250,
	shoot_cooldown = 0.5,
	bullet_speed = 400,
	currentLevel = 1,
}

Config.OPTIONS = {
	MUSIC = true,
	MUSIC_VOLUME = 0.5,
	SFX_VOLUME = 0.5,
	FULLSCREEN = false,
}

Config.ENEMY_STATS = {
	speed = 200,
	health = 10,
	attack = 1,
	bullet_speed = 400,
	bullet_patterns = {
		"straight",
		"spread",
		"zigzag",
	},
	aimsAtPlayer = false,
	shoot_probability = 0.2,
}

Config.ASSETS = {
	PLAYER_SPRITE = "sprites/player.png",
	BACKGROUND_MUSIC = "audio/main_menu/main_theme.mp3",
	PLAYER_CARD = { path = "sprites/ui/forest/PlayerCardSprite-Sheet.png", width = 110, height = 110 },
	SHIP_SPRITE = "sprites/ui/forest/ship-Sheet.png",
	EMEMY_SPRITE = "sprites/ui/enemy-export-sheet-big.png",
	EXPLOSION_SPRITE = "sprites/ui/forest/explosion-Sheet.png",
}

Config.LEVEL_BACKGROUNDS = {
	LEVEL_1 = {
		preview = "sprites/orig.png",
		sprites = {
			{ sprite = "sprites/ui/forest/1-export.png", speed = 9 }, -- Sprite 1 with speed 9
			{ sprite = "sprites/ui/forest/2-export.png", speed = 3 }, -- Sprite 2 with speed 7
			{ sprite = "sprites/ui/forest/3.png", speed = 3 }, -- Sprite 3 with speed 5
			{ sprite = "sprites/ui/forest/4-export.png", speed = 4 }, -- Non-moveable sprite with speed 0
		},
	},
	LEVEL_2 = {
		preview = "sprites/ui/nature_1/orig.png",
		sprites = {
			{ sprite = "sprites/ui/nature_1/1.png", speed = 9 }, -- Sprite 1 with speed 9
			{ sprite = "sprites/ui/nature_1/2.png", speed = 7 }, -- Sprite 2 with speed 7
			{ sprite = "sprites/ui/nature_1/3.png", speed = 5 }, -- Sprite 3 with speed 5
			{ sprite = "sprites/ui/nature_1/5.png", speed = 0 }, -- Non-moveable sprite with speed 0
			{ sprite = "sprites/ui/nature_1/6.png", speed = 0 }, -- Non-moveable sprite with speed 0
			{ sprite = "sprites/ui/nature_1/7.png", speed = 0 }, -- Non-moveable sprite with speed 0
			{ sprite = "sprites/ui/nature_1/8.png", speed = 0 }, -- Non-moveable sprite with speed 0
			{ sprite = "sprites/ui/nature_1/10.png", speed = 0 }, -- Non-moveable sprite with speed 0
		},
	},
	LEVEL_3 = {
		preview = "sprites/ui/nature_6/orig.png",
		sprites = {
			{ sprite = "sprites/ui/nature_6/1-export.png", speed = 9 }, -- Sprite 1 with speed 9
			{ sprite = "sprites/ui/nature_6/3-export.png", speed = 5 }, -- Sprite 3 with speed 5
		},
	},
	LEVEL_4 = {
		preview = "sprites/ui/nature_6/orig.png",
		sprites = {
			{ sprite = "sprites/ui/nature_5/1.png", speed = 0 }, -- Non-moveable sprite with speed 0
			{ sprite = "sprites/ui/nature_5/2-export.png", speed = 0 }, -- Non-moveable sprite with speed 0
			{ sprite = "sprites/ui/nature_5/3-export.png", speed = 9 }, -- Sprite 3 with speed 9
			{ sprite = "sprites/ui/nature_5/4-export.png", speed = 7 }, -- Sprite 4 with speed 7
		},
	},
}
Config.ENEMY_FORMATIONS = {
	{
		name = "Line",
		rows = 2,
		cols = 10,
		rowSpacing = 105,
		colSpacing = 120,
		unlockLevel = 1,
		movementPatterns = { "horizontalSweep" },
	},
	{
		name = "Wall",
		rows = 3,
		cols = 4,
		rowSpacing = 70,
		colSpacing = 90,
		unlockLevel = 2,
		movementPatterns = { "horizontalSweep", "verticalPulse" },
	},
	{
		name = "Diamond",
		rows = 3,
		cols = 5,
		rowSpacing = 105,
		colSpacing = 120,
		unlockLevel = 3,
		pattern = {
			{ 0, 0, 1, 0, 0 },
			{ 0, 1, 1, 1, 0 },
			{ 1, 1, 1, 1, 1 },
		},
		movementPatterns = { "horizontalSweep", "zigzag" },
	},
}

-- Movement patterns for enemy formations
Config.MOVEMENT_PATTERNS = {
	horizontalSweep = {
		speedX = 100,
		speedY = 0,
		amplitude = 200,
		frequency = 1,
		update = function(formation, dt)
			formation.offsetX = formation.offsetX + formation.speedX * dt
			if formation.offsetX > 200 or formation.offsetX < -200 then
				formation.speedX = -formation.speedX
			end
		end,
	},
	verticalPulse = {
		speedX = 0,
		speedY = 50,
		amplitude = 100,
		frequency = 0.5,
		update = function(formation, dt)
			formation.offsetY = 100 * math.sin(formation.time * 2)
			formation.time = formation.time + dt
		end,
	},
	zigzag = {
		speedX = 150,
		speedY = 0,
		amplitude = 150,
		frequency = 2,
		update = function(formation, dt)
			formation.offsetX = formation.offsetX + formation.speedX * dt
			formation.offsetY = 50 * math.sin(formation.time * 3)
			formation.time = formation.time + dt

			-- Reverse direction at screen edges
			if formation.offsetX > 200 or formation.offsetX < -200 then
				formation.speedX = -formation.speedX
			end
		end,
	},
}

-- Difficulty scaling
Config.DIFFICULTY_SCALING = {
	enemyHealthMultiplier = function(level)
		return 1 + (level * 0.2)
	end,
	enemySpeedMultiplier = function(level)
		return 1 + (level * 0.1)
	end,
	formationDensity = function(level)
		return math.min(1.0, 0.5 + (level * 0.1))
	end,
}
return Config
