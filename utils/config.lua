-- Config.lua
local Config = {}

-- Screen dimensions
Config.SCREEN_WIDTH = love.graphics.getWidth()
Config.SCREEN_HEIGHT = love.graphics.getHeight()

Config.DECK_SIZE = 52
Config.INITIAL_HAND_SIZE = 5

Config.PLAYER_DEFAULTS = {
	mana = 10,
	attack = 5,
	defense = 5,
}

Config.ENEMY_STATS = {
	{ level = 1, attack = 3, defense = 2, reward = "Basic Sword" },
	{ level = 2, attack = 5, defense = 4, reward = "Steel Shield" },
	-- Add more levels as needed
}

Config.ASSETS = {
	PLAYER_SPRITE = "sprites/player.png",
	BACKGROUND_MUSIC = "audio/main_menu/main_theme.mp3",
	PLAYER_CARD = { path = "sprites/ui/forest/PlayerCardSprite-Sheet.png", width = 110, height = 110 },
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

return Config
