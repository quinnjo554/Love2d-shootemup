local EventManager = require("core.EventManager")
local AssetManager = require("core.AssetManager")
local SpriteAnimation = require("ui.SpriteAnimation")
local CONFIG = require("utils.config")
local BattleUI = {}
-- make the background move
function BattleUI:new(eventManager, stateManager, player)
	local battleUI = {
		eventManager = eventManager,
		stateManager = stateManager,
		levelContent = nil,
		backgroundAssets = {},
		count = 0,
		county = 0,
		battleWon = false,
		checkWinTimer = 0,
		playerCardSprite = SpriteAnimation:new(
			CONFIG.ASSETS.PLAYER_CARD.path,
			CONFIG.ASSETS.PLAYER_CARD.width,
			CONFIG.ASSETS.PLAYER_CARD.height,
			5
		),
		gameObjects = {},
		player = player,
	}
	setmetatable(battleUI, { __index = BattleUI })

	battleUI:getLevelContent()

	return battleUI
end

function BattleUI:CheckWinCondition()
	if #self.gameObjects == 0 and not self.battleWon then
		self.battleWon = true
		print("Battle won! Emitting event...")

		-- Emit the battle won event with the current level data
		self.eventManager:emit(EventManager.Types.BATTLE_WON, {
			player = self.player,
		})
	end
end

function BattleUI:getLevelContent()
	self.eventManager:on(EventManager.Types.BATTLE_INITIATED, function(currentLevel)
		self.currentLevel = self.stateManager:get("run.currentLevel")
		self.stateManager:set("battle.isActive", true)
		self.stateManager:set("battle.enemies", currentLevel.enemies)
		self.battleWon = false

		for _, spriteInfo in ipairs(self.currentLevel.paths.sprites) do
			local sprite = spriteInfo.sprite
			local speed = spriteInfo.speed or 0
			table.insert(
				self.backgroundAssets,
				AssetManager:new(sprite, 0, 0, love.graphics.getWidth(), love.graphics.getHeight(), speed)
			)
		end

		self.gameObjects = self.currentLevel.enemies

		print("Battle initiated with level: " .. currentLevel.levelName)
		print("Enemies loaded: " .. #self.gameObjects)
	end)
end

function BattleUI:update(dt)
	--optimize by making an event in enemy for every time its destroyed and emmit it there then on that event checkwincondition
	self.checkWinTimer = (self.checkWinTimer or 0) + dt
	if self.checkWinTimer >= 0.5 then
		self:CheckWinCondition()
		self.checkWinTimer = 0
	end

	if self.backgroundAssets and #self.backgroundAssets > 0 then
		for _, asset in ipairs(self.backgroundAssets) do
			asset:update(dt)
		end
	end

	if self.currentLevel and self.currentLevel.formations then
		for _, formation in ipairs(self.currentLevel.formations) do
			formation:update(dt, self.player)
		end
	end

	if self.player then
		self.player:update(dt, self.gameObjects)
	end

	self.checkWinTimer = self.checkWinTimer + dt
	if self.checkWinTimer >= 0.5 then
		self:CheckWinCondition()
		self.checkWinTimer = 0
	end
end

function BattleUI:draw()
	if self.backgroundAssets and #self.backgroundAssets > 0 then
		for _, asset in ipairs(self.backgroundAssets) do
			asset:draw()
		end
	end

	for _, enemy in ipairs(self.gameObjects) do
		enemy:draw()
	end

	self.player:draw()
end

function table.contains(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

return BattleUI
