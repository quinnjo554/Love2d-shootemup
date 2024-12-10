local love = require "love"
local AssetManager = require "core.AssetManager"
local StartButton = require "StartButton"
local SpriteAnimation = require "ui.SpriteAnimation"
local MainMenuUI = {}

function MainMenuUI:new(onStartGame)
    local object = {
        AssetManager = {},
        -- static background elements
        backgrounds = {
        --AssetManager:new("sprites/ui/nature_5/1.png",0,0, love.graphics.getWidth(), love.graphics.getHeight(),0),  -- Moving clouds
        AssetManager:new("sprites/ui/forest/1-export.png",0,0, love.graphics.getWidth(), love.graphics.getHeight(),10),  -- Moving clouds
        AssetManager:new("sprites/ui/nature_5/3-export.png",0,0, love.graphics.getWidth(), love.graphics.getHeight(),10),  -- Moving clouds
        AssetManager:new("sprites/ui/nature_5/4-export.png",0,0, love.graphics.getWidth() * 1.5, love.graphics.getHeight(),7),  -- Moving clouds
        AssetManager:new("sprites/ui/forest/GameLogo2.png",525,150, love.graphics.getWidth() /2, love.graphics.getHeight() /2, 0),  -- Static background
        },

        -- load non static elements
        --catSprite = SpriteAnimation:new("sprites/ui/forest/CatSprite-Sheet.png",96,96,5),
        startButton = StartButton:new(900,800),
        -- audio
        audio = self:loadAudio(),
    }

    setmetatable(object, {__index = MainMenuUI})

    object.startButton.onClick = function()
    -- Directly call the provided callback when button is clicked
        object.audio.backgroundMusic:stop()
        if onStartGame then
            onStartGame()
        end
      end
      return object

end

function MainMenuUI:loadAudio()
    self.audio = {
        backgroundMusic = love.audio.newSource("audio/main_menu/main_theme.mp3", "stream"),
    }

    self.audio.backgroundMusic:setLooping(true)
    self.audio.backgroundMusic:play()
end

-- move background ui elements
function MainMenuUI:update(dt)
    for _, background in ipairs(self.backgrounds) do
        background:update(dt)
    end

    local mouse_x, mouse_y = love.mouse.getPosition()
    --self.catSprite:update(dt)
    self.startButton:update( mouse_x, mouse_y)


end

-- draw ui elemementrs
function MainMenuUI:draw(index)
    for _, background in ipairs(self.backgrounds) do
      background:draw()
    end
    --self.catSprite:draw(1520,  200,  2)
    -- Draw the start button
    self.startButton:draw()
    -- meed to draw start button isHovered
  --
  love.graphics.print("Start Button isHovered: " .. tostring(self.startButton.isHovered), 100, 160)
end
function MainMenuUI:handleMousePress(x, y, button)
    if self.startButton and self.startButton.handleMousePress then
        self.startButton:handleMousePress(x, y, button)
    end
end


return MainMenuUI
