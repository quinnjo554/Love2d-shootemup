local love = require "love"
-- entities/Player.lua
local Deck = require "entities.Deck"
-- local RuneCollection = require "entities.RuneCollection"

local Player = {}
Player.__index = Player

function Player:new(name)
 local player = {
        mana = stats.mana or Config.PLAYER_DEFAULTS.mana,
        attack = stats.attack or Config.PLAYER_DEFAULTS.attack,
        defense = stats.defense or Config.PLAYER_DEFAULTS.defense,
        hand = {},
        deck = {}, -- Fill with Card objects
       -- give invisible level for unlocks
    }
    
    setmetatable(player, self)
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
