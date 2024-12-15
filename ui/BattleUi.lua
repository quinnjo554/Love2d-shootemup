local EventManager = require("core.EventManager")
local AssetManager = require("core.AssetManager")
local SpriteAnimation = require("ui.SpriteAnimation")
local CONFIG = require("utils.config")
local BattleUI = {}

-- make the background move
function BattleUI:new(eventManager, player)
	local battleUI = {
		eventManager = eventManager,
		player = player,
		levelContent = nil,
		backgroundAssets = {},
		playerCardSprite = SpriteAnimation:new(
			CONFIG.ASSETS.PLAYER_CARD.path,
			CONFIG.ASSETS.PLAYER_CARD.width,
			CONFIG.ASSETS.PLAYER_CARD.height,
			5
		),
	}
	setmetatable(battleUI, { __index = BattleUI })

	battleUI:getLevelContent()
	return battleUI
end

-- this is from levelModel change so gameManger is the one sending ie levelModel -> gameManger -> BattleUI
function BattleUI:getLevelContent()
	self.eventManager:on(EventManager.Types.BATTLE_INITIATED, function(currentLevel)
		for _, spriteInfo in ipairs(currentLevel.paths.sprites) do
			local sprite = spriteInfo.sprite
			local speed = spriteInfo.speed or 0

			table.insert(
				self.backgroundAssets,
				AssetManager:new(sprite, 0, 0, love.graphics.getWidth(), love.graphics.getHeight(), speed)
			)
		end
	end)
end

function BattleUI:update(dt)
	if self.backgroundAssets and #self.backgroundAssets > 0 then
		for _, asset in ipairs(self.backgroundAssets) do
			asset:update(dt)
		end
	end
	self.playerCardSprite:update(dt)
	self.player.deck:update(dt)
end

function BattleUI:draw()
	if self.backgroundAssets and #self.backgroundAssets > 0 then
		-- Iterate through all assets and draw each one
		for _, asset in ipairs(self.backgroundAssets) do
			asset:draw()
		end
	end

	self.player.deck:draw()
	self.playerCardSprite:draw(100, 100, 1)
end

function handleMouseMoved(x, y)
	self.player.deck:handleMouseMoved()
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
