-- core/EventManager.lua

local EventManager = {}

function EventManager:new()
	local obj = {
		-- Store event listeners organized by event type
		listeners = {},
		-- Optional queue for events that can be processed later
		eventQueue = {},
	}
	setmetatable(obj, { __index = self })
	return obj
end

-- Subscribe to an event type
function EventManager:on(eventType, listener)
	if not self.listeners[eventType] then
		self.listeners[eventType] = {}
	end
	table.insert(self.listeners[eventType], listener)
	return #self.listeners[eventType] -- Return listener index
end

-- Unsubscribe from an event
function EventManager:off(eventType, listenerIndex)
	if self.listeners[eventType] and self.listeners[eventType][listenerIndex] then
		table.remove(self.listeners[eventType], listenerIndex)
	end
end

-- Emit an event to all listeners of that type
function EventManager:emit(eventType, ...)
	if self.listeners[eventType] then
		for _, listener in ipairs(self.listeners[eventType]) do
			listener(...)
		end
	end
end

-- Queue an event to be processed later
function EventManager:queue(eventType, ...)
	table.insert(self.eventQueue, { type = eventType, args = { ... } })
end

-- Process all queued events
function EventManager:processQueue()
	while #self.eventQueue > 0 do
		local event = table.remove(self.eventQueue, 1)
		self:emit(event.type, unpack(event.args))
	end
end

-- Example event types (you can expand these)
EventManager.Types = {
	STATE_CHANGED = "state_changed",
	LEVEL_STARTED = "level_started",
	BATTLE_INITIATED = "battle_initiated",
	GAME_OVER = "game_over",
	PLAYER_MOVED = "player_moved",
	CURRENT_RUN_PATH_RESPONSE = "current_run_path_response",
	CURRENT_LEVEL_RESPONSE = "current_level_response",
	REQUEST_CURRENT_RUN_PATH = "request_current_run_path",
	REQUEST_CURRENT_LEVEL = "request_current_level",
}

return EventManager
