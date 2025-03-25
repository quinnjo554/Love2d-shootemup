local StateManager = {}
StateManager.__index = StateManager

function StateManager:new()
	local manager = setmetatable({}, self)

	manager.state = {
		currentScreen = "MAIN_MENU", -- MAIN_MENU, LEVEL, BATTLE, etc.

		player = {
			health = 0,
			maxHealth = 0,
			x = 0,
			y = 0,
			width = 0,
			height = 0,
			speed = 0,
			damage = 0,
			shield = 0,
			direction = "idle",
			bullets = {},
			lastShootTime = 0,
			shootCooldown = 0,
			isDead = false,
		},

		run = {
			currentLevel = nil,
			currentPath = nil,
			paths = nil, -- Will hold LinkedList instance
			levelsCompleted = {},
			currentProgress = 0,
		},

		battle = {
			isActive = false,
			enemies = {},
			backgroundAssets = {},
			battleWon = false,
		},

		ui = {
			backgrounds = {},
		},

		options = {
			music = true,
			musicVolume = 0.5,
			sfxVolume = 0.5,
			fullscreen = false,
		},
	}

	manager.subscribers = {}

	return manager
end

function StateManager:init(config)
	self:set("player.health", config.PLAYER_STATS.health)
	self:set("player.maxHealth", config.PLAYER_STATS.health)
	self:set("player.damage", config.PLAYER_STATS.damage)
	self:set("player.shield", config.PLAYER_STATS.shield)
	self:set("player.speed", config.PLAYER_STATS.speed)
	self:set("player.shootCooldown", config.PLAYER_STATS.shoot_cooldown)
	self:set("player.x", config.SCREEN_WIDTH + 100)
	self:set("player.y", config.SCREEN_HEIGHT * 1.5)
	self:set("player.width", 64)
	self:set("player.height", 96)

	self:set("options.music", config.OPTIONS.MUSIC)
	self:set("options.musicVolume", config.OPTIONS.MUSIC_VOLUME)
	self:set("options.sfxVolume", config.OPTIONS.SFX_VOLUME)
	self:set("options.fullscreen", config.OPTIONS.FULLSCREEN)
end

-- path: string, e.g. "player.health", "options.music"
function StateManager:get(path)
	if not path then
		return self.state
	end

	local parts = {}
	for part in string.gmatch(path, "([^.]+)") do
		table.insert(parts, part)
	end

	local current = self.state
	for _, part in ipairs(parts) do
		if current[part] == nil then
			return nil
		end
		current = current[part]
	end

	return current
end

function StateManager:set(path, value)
	if not path then
		error("Path must be specified for set operation")
		return
	end

	local parts = {}
	for part in string.gmatch(path, "([^.]+)") do
		table.insert(parts, part)
	end

	local current = self.state
	local lastPart = table.remove(parts, #parts)

	for _, part in ipairs(parts) do
		if current[part] == nil then
			current[part] = {}
		end
		current = current[part]
	end

	local oldValue = current[lastPart]
	current[lastPart] = value

	self:notifySubscribers(path, value, oldValue)

	return value
end

-- callback: function(newValue, oldValue, path)
function StateManager:subscribe(path, callback)
	if not self.subscribers[path] then
		self.subscribers[path] = {}
	end

	table.insert(self.subscribers[path], callback)
	return #self.subscribers[path] -- Return index for unsubscribe
end

function StateManager:unsubscribe(path, index)
	if self.subscribers[path] and self.subscribers[path][index] then
		table.remove(self.subscribers[path], index)
	end
end

function StateManager:notifySubscribers(path, newValue, oldValue)
	if self.subscribers[path] then
		for _, callback in ipairs(self.subscribers[path]) do
			callback(newValue, oldValue, path)
		end
	end

	local pathParts = {}
	for part in string.gmatch(path, "([^.]+)") do
		table.insert(pathParts, part)
	end

	while #pathParts > 0 do
		table.remove(pathParts)
		local parentPath = table.concat(pathParts, ".")

		if parentPath ~= "" and self.subscribers[parentPath] then
			local parentValue = self:get(parentPath)
			for _, callback in ipairs(self.subscribers[parentPath]) do
				callback(parentValue, nil, parentPath)
			end
		end
	end

	-- Global state change notification
	if self.subscribers["*"] then
		for _, callback in ipairs(self.subscribers["*"]) do
			callback(self.state, nil, "*")
		end
	end
end

return StateManager
