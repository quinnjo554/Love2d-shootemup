-- core/GameManager.lua
-- TODO: Take funtionality from main.lua and put it in GameManager.lua
-- TODO: Make a asset manager so you can store the image, x,y,width, height, etc in one place

local ImageManager = require "core.ImageManager"

local UIManager = {}
UIManager.__index = UIManager

function UIManager:new()
    local manager = setmetatable({}, self)
    manager.currentScreen = nil
    manager.battleScreen = nil
    manager.mainMenu = nil
    manager.deckBuilder = nil
    manager.images = AssetsManager:new()
    return manager
end

function UIManager:loadImages()
    self.images["background"] = love.graphics.newImage("assets/background.png")
    self.images["card"] = love.graphics.newImage("assets/card.png")
    self.images["button"] = love.graphics.newImage("assets/button.png")
end

-- Main menu screen will just be Background and a button


UiManager.mainMenu = {
    backgroundAsset = self.images["background"],
    button = nil
}

function UIManager:SetCurrentScreen(screen)
    if screen == "MAIN_MENU" then
       self.currentScreen = self.mainMenu
    elseif screen == "DECK_BUILDER" then
      self.currentScreen = self.deckBuilder
    end
end
