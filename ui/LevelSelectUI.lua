local love = require "love"
local AssetManager = require "core.AssetManager"
local StartButton = require "StartButton"
local SpriteAnimation = require "ui.SpriteAnimation"
local LevelSelectUI = {}

local time = 0
function LevelSelectUI:new(onStartGame)
    local object = {
        magicMirrorShader = love.graphics.newShader("utils/mirrorShader.glsl"),

        AssetManager = {},
        -- static background elements
        backgrounds = {


        AssetManager:new("sprites/ui/nature_5/origbig.png",0,0, love.graphics.getWidth(), love.graphics.getHeight(),0),  -- Moving clouds
        AssetManager:new("sprites/ui/nature_6/origbig.png",0,0, love.graphics.getWidth(), love.graphics.getHeight(),0),  -- Moving clouds
        AssetManager:new("sprites/ui/forest/mirrorImg2.png",love.graphics.getWidth()/3,love.graphics.getHeight()-450, love.graphics.getWidth()/3, love.graphics.getHeight()/3,0),  -- Moving clouds
        },

        -- load non static elements
        startButton = StartButton:new(900,800),
        -- audio
    }

    setmetatable(object, {__index = LevelSelectUI})

    object.startButton.onClick = function()
    -- Directly call the provided callback when button is clicked
        if onStartGame then
            onStartGame()
        end
      end
      return object

end

function LevelSelectUI:loadAudio()
    self.audio = {
        backgroundMusic = love.audio.newSource("audio/main_menu/main_theme.mp3", "stream"),
    }
end

-- move background ui elements
function LevelSelectUI:update(dt)
self.time = (self.time or 0) + dt -- Increment time
    self.magicMirrorShader:send("SCREEN_SIZE", {love.graphics.getWidth(), love.graphics.getHeight()})
    self.magicMirrorShader:send("TIME", self.time)

    for _, background in ipairs(self.backgrounds) do
        background:update(dt)
    end

    local mouse_x, mouse_y = love.mouse.getPosition()
    self.startButton:update( mouse_x, mouse_y)

end

-- draw ui elemementrs
function LevelSelectUI:draw(index)
    for i, background in ipairs(self.backgrounds) do
      if i == 1 then
          love.graphics.setShader(self.magicMirrorShader)
      end
      background:draw()
      love.graphics.setShader()
    end
    self.startButton:draw()
end
function LevelSelectUI:handleMousePress(x, y, button)
    if self.startButton and self.startButton.handleMousePress then
        self.startButton:handleMousePress(x, y, button)
    end
end


return LevelSelectUI
