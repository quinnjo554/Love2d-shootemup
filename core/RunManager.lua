local RunManager = {}
local LinkedList = require("utils.LinkedList")
local Level = require("levels.Level")
local EventManager = require("core.EventManager")
local CONFIG = require("utils.config")

function RunManager:new(eventManager, stateManager, player)
	local manager = {
		eventManager = eventManager,
		stateManager = stateManager,
		player = player,
	}

	setmetatable(manager, { __index = RunManager })
	local paths = LinkedList:new()

	manager.stateManager:set("run.paths", paths)
	manager.stateManager:set("run.currentProgress", 0)
	manager.stateManager:set("run.levelsCompleted", {})

	manager:InitPaths()

	manager.stateManager:set("run.currentPath", paths:peekFirst())
	return manager
end

function RunManager:setCurrentLevel(level)
	self.stateManager:set("run.currentLevel", level)
end

function RunManager:getCurrentLevel()
	return self.stateManager:get("run.currentLevel")
end

function RunManager:InitPaths()
	--paths
	local paths = self.stateManager:get("run.paths")
	love.math.setRandomSeed(os.time())
	for i = 1, 10 do
		local levelArray = {}
		-- generate a random number of levels
		for j = 1, love.math.random(1, 3) do
			local random = love.math.random(1, 3)
			local img = self:generateImage(random)
			table.insert(levelArray, Level:new("level", img.preview, img, self.player, self.stateManager))
		end
		paths:append(levelArray)
	end
end

function RunManager:peekNextPath()
	local paths = self.stateManager:get("run.paths")
	return paths:peekNext(paths:peekFirst())
end

function RunManager:CurrPath()
	local paths = self.stateManager:get("run.paths")
	return paths:peekFirst()
end

function RunManager:generateImage(random)
	if random == 1 then
		return CONFIG.LEVEL_BACKGROUNDS.LEVEL_1
	elseif random == 2 then
		return CONFIG.LEVEL_BACKGROUNDS.LEVEL_2
	elseif random == 3 then
		return CONFIG.LEVEL_BACKGROUNDS.LEVEL_3
	elseif random == 4 then
		return CONFIG.LEVEL_BACKGROUNDS.LEVEL_4
	else
		return CONFIG.LEVEL_BACKGROUNDS.LEVEL_1
	end
end

function RunManager:setupPathRequestHandler()
	self.eventManager:on(EventManager.Types.REQUEST_CURRENT_RUN_PATH, function()
		local currentPath = self:CurrPath()
		self.stateManager:set("run.currentPath", currentPath)
		self.eventManager:emit(EventManager.Types.CURRENT_RUN_PATH_RESPONSE, { currentPath = currentPath })
	end)
end

return RunManager
