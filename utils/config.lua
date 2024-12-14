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
    {level = 1, attack = 3, defense = 2, reward = "Basic Sword"},
    {level = 2, attack = 5, defense = 4, reward = "Steel Shield"},
    -- Add more levels as needed
}

Config.ASSETS = {
    PLAYER_SPRITE = "sprites/player.png",
    BACKGROUND_MUSIC = "audio/main_menu/main_theme.mp3",
}

return Config
