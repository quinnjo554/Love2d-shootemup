-- entities/Player.lua
local Deck = require "entities.Deck"
local RuneCollection = require "entities.RuneCollection"

local Player = {}
Player.__index = Player

function Player:new(name)
    local player = setmetatable({}, self)
    
    player.name = name
    player.level = 1
    player.experience = 0
    
    -- Multiple decks for different strategies
    player.decks = {
        default = Deck:new(),
        aggressive = Deck:new(),
        defensive = Deck:new()
    }
    
    -- Rune management
    player.runeCollection = RuneCollection:new()
    
    -- Player progression stats
    player.stats = {
        health = 100,
        mana = 100,
        maxHealth = 100,
        maxMana = 100
    }
    
    return player
end

function Player:levelUp()
    self.level = self.level + 1
    
    -- Increase base stats on level up
    self.stats.maxHealth = self.stats.maxHealth + 10
    self.stats.maxMana = self.stats.maxMana + 5
    
    -- Potentially unlock new deck slots or rune types
    if self.level % 5 == 0 then
        self:unlockNewFeature()
    end
end

function Player:addExperience(amount)
    self.experience = self.experience + amount
    
    -- Check if player can level up
    local experienceThreshold = self.level * 100
    if self.experience >= experienceThreshold then
        self:levelUp()
        self.experience = self.experience - experienceThreshold
    end
end

function Player:selectDeck(deckName)
    return self.decks[deckName] or self.decks.default
end

function Player:unlockNewFeature()
    -- Example of unlocking new mechanics
    print("New feature unlocked at level " .. self.level)
end

return Player
