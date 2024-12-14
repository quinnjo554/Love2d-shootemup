local EventManager = require("core.EventManager")
local AssetManager = require("core.AssetManager")
local BattleUI = {}

-- make the background move
function BattleUI:new(eventManager)
	local battleUI = {
		eventManager = eventManager,
		player = nil,
		levelContent = nil,
		back = nil,
	}
	setmetatable(battleUI, { __index = BattleUI })

	battleUI:getLevelContent()
	return battleUI
end

-- this is from levelModel change so gameManger is the one sending ie levelModel -> gameManger -> BattleUI
function BattleUI:getLevelContent()
	self.eventManager:on(EventManager.Types.BATTLE_INITIATED, function(currentLevel)
		self.back = AssetManager:new(currentLevel.path, 0, 0, love.graphics.getWidth(), love.graphics.getHeight(), 0)
	end)
end

function BattleUI:update() end

function BattleUI:draw()
	if self.back then
		self.back:draw()
	end
end

return BattleUI
