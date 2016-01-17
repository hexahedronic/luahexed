local event = {}
local listeners = {}

function event.listen(eventName, identifier, callback)
	assertType(eventName, "string")
	assertType(identifier, "string")
	assertType(callback, "function")

	if not listeners[eventName] then
		listeners[eventName] = {}
	end

  	listeners[eventName][identifier] = callback
end

function event.remove(eventName, identifier)
	assertType(eventName, "string")
	assertType(identifier, "string")

	if not listeners[eventName] then return end

	listeners[eventName][identifier] = nil
end

function event.call(eventName, ...)
	assertType(eventName, "string")

	if not listeners[eventName] then return end

	local a, b, c, d, e, f, g, h
	for identifier, callback in pairs(listeners[eventName]) do
		a, b, c, d, e, f, g, h = callback(...)
	end

	return a, b, c, d, e, f, g, h
end

function event.getTable()
	return listeners
end

return event
