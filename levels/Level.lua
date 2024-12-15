local Level = {}

function Level:new(name, previewPath, imgs)
	local level = setmetatable({}, self)
	level.previewImg = love.graphics.newImage(previewPath)
	level.previewPath = previewPath
	level.paths = imgs
	level.reward = "Reward: 1000" -- change to real object
	level.Enemies = nil
	level.levelName = name
	level.winCondition = ""
	return level
end

return Level
