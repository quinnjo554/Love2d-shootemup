-- battle/BattleSystem.lua
local BattleSystem = {}
BattleSystem.__index = BattleSystem

-- Battle states
local BATTLE_STATES = {
    PREPARATION = "preparation",
    PLAYER_TURN = "player_turn",
    ENEMY_TURN = "enemy_turn",
    RESOLUTION = "resolution",
    FINISHED = "finished"
}

function BattleSystem:new(player, enemy, level)
    local battle = setmetatable({}, self)
    
    battle.player = player
    battle.enemy = enemy
    battle.level = level
    
    -- Current battle state
    battle.state = BATTLE_STATES.PREPARATION
    
    -- Battle parameters from level
    battle.turnLimit = level.turnLimit or 10
    battle.currentTurn = 0
    
    -- Battle metrics
    battle.metrics = {
        playerDamageDealt = 0,
        enemyDamageDealt = 0,
        specialCombosActivated = 0
    }
    
    return battle
end

function BattleSystem:startBattle()
    self.state = BATTLE_STATES.PLAYER_TURN
    
    -- Apply level-specific modifiers
    self:applyLevelModifiers()
end

function BattleSystem:processPlayerTurn(selectedCards)
    -- Validate turn
    if self.state ~= BATTLE_STATES.PLAYER_TURN then
        error("Not player's turn")
    end
    
    -- Resolve card effects
    local battleResult = self:resolveCardPlay(selectedCards)
    
    -- Update battle state
    self:updateBattleMetrics(battleResult)
    
    -- Switch to enemy turn
    self.state = BATTLE_STATES.ENEMY_TURN
    self.currentTurn = self.currentTurn + 1
    
    return battleResult
end

function BattleSystem:resolveCardPlay(selectedCards)
    -- Complex card effect resolution
    local totalDamage = 0
    local specialCombo = false
    
    -- Check for special combinations
    if #selectedCards >= 3 then
        local cardTypes = self:categorizeCards(selectedCards)
        if cardTypes.fire >= 3 then
            specialCombo = true
            totalDamage = totalDamage * 1.5
        end
    end
    
    -- Calculate base damage
    for _, card in ipairs(selectedCards) do
        totalDamage = totalDamage + card.power
    end
    
    return {
        damage = totalDamage,
        specialCombo = specialCombo
    }
end

function BattleSystem:categorizeCards(cards)
    local categories = {
        fire = 0,
        water = 0,
        earth = 0
        -- Add more categories
    }
    
    for _, card in ipairs(cards) do
        local type = self:determineCardType(card)
        categories[type] = categories[type] + 1
    end
    
    return categories
end

function BattleSystem:determineCardType(card)
    -- Logic to determine card type based on image or properties
    if string.find(card.imagePath, "fire") then
        return "fire"
    end
    -- Add more type detection
    return "generic"
end

function BattleSystem:updateBattleMetrics(turnResult)
    self.metrics.playerDamageDealt = 
        self.metrics.playerDamageDealt + turnResult.damage
    
    if turnResult.specialCombo then
        self.metrics.specialCombosActivated = 
            self.metrics.specialCombosActivated + 1
    end
    
    -- Check battle completion conditions
    if self.currentTurn >= self.turnLimit then
        self.state = BATTLE_STATES.FINISHED
    end
end

return BattleSystem
