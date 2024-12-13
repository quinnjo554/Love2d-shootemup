local love = require "love"
local AssetManager = require "core.AssetManager"
local StartButton = require "StartButton"
local SpriteAnimation = require "ui.SpriteAnimation"
local CreateCommonBackgrounds = require "utils.sharedBackgrounds.sharedBackgrounds"
local CutsceneSprite = require "ui.AnimatedSprite"
local EventManager   = require "core.EventManager"
local LevelSelectUI = {}
local shallowcopy = require "utils.copyTable"

-- TODO: remove magic numbers and use constants
--TODO: CLEAN UP CODE
local LevelModel = require "entities.levelModel"

local MODEL_WIDTH = 700
local MODEL_HEIGHT = 700


-- TODO: dont pass gameManager just pass the thing needed by the object
function LevelSelectUI:new(eventManager, backgrounds)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local object = {
        AssetManager = {},
        levels = nil,
        eventManager = eventManager,
        catCutsceneSprite = CutsceneSprite:new({x = -240 , y = 935, speed = 4, targetX = screenWidth / 2 - 96, targetY = 935, spriteSheet = "sprites/ui/forest/CatSprite-Sheet.png", spriteFrames = 7 , frameWidth = 96, frameHeight = 96, spriteScale = 1}),
        playerCutsceneSprite = CutsceneSprite:new({x = -150, y = 900, speed = 4, targetX = screenWidth / 2, targetY = 900, spriteSheet = "sprites/ui/Player-Sheet-export.png", frameWidth = 128, frameHeight = 128, spriteFrames = 7, spriteScale = 1}),
        backgrounds = shallowcopy(backgrounds),
        levelSelectModel = nil,
        audio = self:loadAudio(),
    }

    setmetatable(object, {__index = LevelSelectUI})

    -- Initialize cutscene sprites
    object:initializeCutsceneSprite()

    object:loadLevelModel()
    -- Emit the request event for the current run path

    return object
end


function LevelSelectUI:initializeCutsceneSprite()
    self.playerCutsceneSprite:startCutscene()
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

function LevelSelectUI:loadLevelModel()
 local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()


 self.eventManager:on(EventManager.Types.CURRENT_RUN_PATH_RESPONSE, function(pathData)
        love.window.setTitle("Level Select")
        self.levels = pathData.currentPath
        self.levelSelectModel = LevelModel:new(
            (screenWidth / 2) - MODEL_WIDTH / 2,
            (screenHeight / 2) - MODEL_HEIGHT / 2,
            MODEL_WIDTH,
            MODEL_HEIGHT,
            self.levels,
            function()
                self.eventManager:emit(EventManager.Types.STATE_CHANGED, "BATTLE")
            end
        )
    end)

  
  self.eventManager:emit(EventManager.Types.REQUEST_CURRENT_RUN_PATH)

   
end

function LevelSelectUI:setInitialBackgrounds(backgrounds)
    -- Option 1: Direct copy
    self.backgrounds = backgrounds
    -- Option 2: Create a smooth transition effect
    for _, bg in ipairs(backgrounds) do
        table.insert(self.backgrounds, bg)
    end
end
-- move background ui elements
function LevelSelectUI:update(dt)
    for _, background in ipairs(self.backgrounds) do
        background:update(dt)
    end
    local mouse_x, mouse_y = love.mouse.getPosition()
  self.playerCutsceneSprite:update(dt)
  self.catCutsceneSprite:update(dt)
  if self.levelSelectModel then
    self.levelSelectModel:update(dt,mouse_x,mouse_y)
  end
end

-- draw ui elemementrs
function LevelSelectUI:draw(index)
    for i, background in ipairs(self.backgrounds) do
      background:draw()
    end
  self.playerCutsceneSprite:draw()
  self.catCutsceneSprite:draw()
  if self.levelSelectModel then
    self.levelSelectModel:draw()
  end

end

function LevelSelectUI:handleMousePress(x, y, button)
  if self.levelSelectModel then
    self.levelSelectModel:mousepressed(x,y,button)
  end
end


return LevelSelectUI
