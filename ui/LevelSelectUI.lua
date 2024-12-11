local love = require "love"
local AssetManager = require "core.AssetManager"
local StartButton = require "StartButton"
local SpriteAnimation = require "ui.SpriteAnimation"
local CreateCommonBackgrounds = require "utils.sharedBackgrounds.sharedBackgrounds"
local CutsceneSprite = require "ui.AnimatedSprite"
local LevelSelectUI = {}
local shallowcopy = require "utils.copyTable"

function LevelSelectUI:new(gameManager,backgrounds)
local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
  local object = {
        AssetManager = {},
        gameManager = gameManager,
 pauCutscene = nil,
        spriteConfig = {
            startX = -100,
            startY = 900,  -- Bottom of the screen
            speed = 50,
            targetX = screenWidth / 2,
            targetY = 900, 
            spriteSheet = "sprites/ui/Player-Sheet-export.png",
            frameWidth = 128,   -- Add frame width explicitly
            frameHeight = 128,
            spriteFrames = 7,
            spriteScale = 1
        },
    carCutscene = nil,
    catConfig = {
            startX = -190,
            startY = 935,  -- Bottom of the screen
            speed = 50,
            targetX = (screenWidth / 2) - 96,
            targetY = 935, 
            spriteSheet = "sprites/ui/forest/CatSprite-Sheet.png",
            frameWidth = 96,   -- Add frame width explicitly
            frameHeight = 96,
            spriteFrames = 7,
            spriteScale = 1

    },
                 -- static background elements
        backgrounds = shallowcopy(backgrounds),
        -- load non static elements
         --pauSprite = SpriteAnimation:new("sprites/ui/Player.png",96,96,5),
        -- audio
        audio = self:loadAudio(),
    }

     setmetatable(object, {__index = LevelSelectUI})


    object:initializeCutsceneSprite()

     return object

end


function LevelSelectUI:initializeCutsceneSprite()
    -- Ensure proper initialization with explicit coordinates
    local config = self.spriteConfig
    local catConfig = self.catConfig
    
    self.catCutsceneSprite = CutsceneSprite:new({
      x = catConfig.startX,
      y = catConfig.startY,
      speed = catConfig.speed,
      targetX = catConfig.targetX,
      targetY = catConfig.targetY,
      spriteSheet = catConfig.spriteSheet,
      spriteFrames = catConfig.spriteFrames,
      frameWidth = catConfig.frameWidth,
      frameHeight = catConfig.frameHeight,
      spriteScale = catConfig.spriteScale
    })
    -- Create a debug version that logs initialization
    self.customCutsceneSprite = CutsceneSprite:new({
        x = config.startX,
        y = config.startY,
        speed = config.speed,
        targetX = config.targetX,
        targetY = config.targetY,
        spriteSheet = config.spriteSheet,
        spriteFrames = config.spriteFrames,
        frameWidth = config.frameWidth,
        frameHeight = config.frameHeight,
        spriteScale = config.spriteScale
    })
    
    -- Start the cutscene movement
    self.customCutsceneSprite:startCutscene()
    self.catCutsceneSprite:startCutscene()
    
end

function LevelSelectUI:loadAudio()
    self.audio = {
        backgroundMusic = love.audio.newSource("audio/main_menu/main_theme.mp3", "stream"),
    }
    self.audio.backgroundMusic:setLooping(true)
    self.audio.backgroundMusic:play()
    self.audio.backgroundMusic:setVolume(0)
end

function LevelSelectUI:setInitialBackgrounds(backgrounds)
    -- Option 1: Direct copy
    self.backgrounds = backgrounds

    -- Option 2: Create a smooth transition effect
    for _, bg in ipairs(backgrounds) do
        -- You might want to adjust position, speed, etc.
        table.insert(self.backgrounds, bg)
    end
end
-- move background ui elements
function LevelSelectUI:update(dt)
    if self.gameManager.currentState == "LEVEL" then
      self.audio.backgroundMusic:setVolume(0.5)
    end
    for _, background in ipairs(self.backgrounds) do
        background:update(dt)
    end
    local mouse_x, mouse_y = love.mouse.getPosition()
  self.customCutsceneSprite:update(dt)
  self.catCutsceneSprite:update(dt)
end

-- draw ui elemementrs
function LevelSelectUI:draw(index)
    for i, background in ipairs(self.backgrounds) do
      background:draw()
    end
  self.customCutsceneSprite:draw()
  self.catCutsceneSprite:draw()

  -- debug customCutsceneSprite
end
function LevelSelectUI:handleMousePress(x, y, button)
end


return LevelSelectUI
