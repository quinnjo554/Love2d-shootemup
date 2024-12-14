local RunManager = {}
local LinkedList = require("utils.LinkedList")
local Level = require("levels.Level")

function RunManager:new(eventManager)
	local manager = {
		paths = LinkedList.new(), -- lined list of level arrays
		currentLevel = nil,
		levelsCompleted = {}, -- for not giving duplicate enemies and levels if I want to make each unique
		currentProgress = 0, -- how far in the run are you
		currentBoonsEquiped = {}, -- make a config of all possible boons and ones that can be unlocked perminantly vs in run boons
	}

	setmetatable(manager, { __index = RunManager })

	manager.currentLevel = manager.paths:peekFirst()
	manager:InitPaths()
	manager:setupPathRequestHandler(eventManager)
	return manager
end

function RunManager:setCurrentLevel(level)
	self.currentlevel = level
end

function RunManager:getCurrentLevel()
	return self.currentlevel
end

function RunManager:InitPaths()
	--paths
	love.math.setRandomSeed(os.time())
	for i = 1, 10 do
		local levelArray = {}
		-- generate a random number of levels
		for j = 1, love.math.random(1, 3) do
			local random = love.math.random(1, 3)
			local img = self:generateImage(random)
			table.insert(levelArray, Level:new("level", img))
		end
		self.paths:append(levelArray)
	end
end

function RunManager:peekNextPath()
	return self.paths:peekNext(self.paths:peekFirst())
end

function RunManager:CurrPath()
	return self.paths:peekFirst()
end

function RunManager:generateImage(random)
	if random == 1 then
		return "sprites/ui/nature_1/orig.png"
	elseif random == 2 then
		return "sprites/ui/nature_5/orig.png"
	elseif random == 3 then
		return "sprites/ui/nature_6/orig.png"
	elseif random == 4 then
		return "sprites/orig.png"
	else
		return "sprites/orig.png"
	end
end

function RunManager:setupPathRequestHandler(eventManager) end

return RunManager
