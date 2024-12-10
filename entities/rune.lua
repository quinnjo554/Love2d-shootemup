local love = require "love"
-- entities/Rune.lua
local Rune = {}
Rune.__index = Rune

-- Rune types and their potential effects
local RUNE_TYPES = {
    POWER = {
        -- Increases card power
        modifier = function(card, value) 
            card.power = card.power * (1 + value) 
        end
    },
    MANA = {
        -- Reduces mana cost
        modifier = function(card, value) 
            card.manaCost = card.manaCost * (1 - value) 
        end
    },
    SPECIAL_EFFECT = {
        -- Adds unique card behaviors
        modifier = function(card, effectType) 
            card.specialEffect = effectType 
        end
    }
}

function Rune:new(type, value)
    local rune = setmetatable({}, self)
    
    rune.id = love.math.random(1000, 9999)
    rune.type = type
    rune.value = value
    rune.level = 1
    
    return rune
end

function Rune:apply(target)
    local runeType = RUNE_TYPES[self.type]
    if runeType then
        runeType.modifier(target, self.value)
    end
end

function Rune:upgrade()
    self.level = self.level + 1
    -- Potentially increase effectiveness
    self.value = self.value * 1.1
end

-- Rune Collection Management
local RuneCollection = {}
RuneCollection.__index = RuneCollection

function RuneCollection:new()
    local collection = setmetatable({}, self)
    collection.runes = {}
    return collection
end

function RuneCollection:addRune(rune)
    table.insert(self.runes, rune)
end

function RuneCollection:getRunesByType(type)
    local matchingRunes = {}
    for _, rune in ipairs(self.runes) do
        if rune.type == type then
            table.insert(matchingRunes, rune)
        end
    end
    return matchingRunes
end

function RuneCollection:applyRunesToDeck(deck)
    for _, card in ipairs(deck.cards) do
        for _, rune in ipairs(self.runes) do
            rune:apply(card)
        end
    end
end

return {
    Rune = Rune,
    RuneCollection = RuneCollection
}
