-- core/GameManager.lua
-- TODO: Take funtionality from main.lua and put it in GameManager.lua
-- TODO: Make a asset manager so you can store the image, x,y,w,z
local love = require "love"
local MainMenuUI = require "ui/MainMenuUI"
local LevelSelectUI = require "ui/LevelSelectUI"
local CreateCommonBackgrounds = require "utils.sharedBackgrounds.sharedBackgrounds"
local UIManager = {}

local sharedBackgrounds = CreateCommonBackgrounds()
function UIManager:new(gameManager)
    local object = {
     -- deckBuilder = nil,
      currentScreen = "",
      gameManager = nil,
      mainMenu = MainMenuUI:new(function ()
          if gameManager then
          gameManager:transitionToState("LEVEL")
          end
      end, sharedBackgrounds),
      level = LevelSelectUI:new(gameManager,sharedBackgrounds),
          
    }
    setmetatable(object, {__index = UIManager})
   
    return object
end
-- Main menu screen will just be Background and a button

function UIManager:SetCurrentScreen(screen)
    if screen == "MAIN_MENU" then
       self.currentScreen = self.mainMenu
    elseif screen == "DECK_BUILDER" then
      self.currentScreen = self.deckBuilder
    elseif screen == "BATTLE" then
      self.currentScreen = self.battle
    elseif screen == "LEVEL" then
      self.currentScreen = self.level
    end
end

function UIManager:handleMousePress(x, y, button)
    if self.currentScreen and self.currentScreen.handleMousePress then
        self.currentScreen:handleMousePress(x, y, button)
    end
end

function UIManager:HandleMouseMoved(x, y)
    if self.currentScreen and self.currentScreen.handleMouseMoved then
        self.currentScreen:handleMouseMoved(x, y)
    end
end

function UIManager:Update(dt, mouse_x, mouse_y)
    self.currentScreen:update(dt, mouse_x, mouse_y)
end

function UIManager:Draw()
    self.currentScreen:draw()
end
return UIManager
