local object = {}
local metatables = {}

function object.register(name, meta, baseclass)
	local function call(self, ...) return object.new(name, ...) end
	setmetatable(meta, {__call = call})

	metatables[name] = meta

	if baseclass then
		metatables[name].baseclass = metatables[baseclass]
		setmetatable(metatables[name], {__index = metatables[baseclass]})
	end
end

function object.registerBase(name, meta)
	metatables[name] = meta
end

function object.new(name, ...)
	local obj = {}
	setmetatable(obj, {__index = metatables[name]})

	if obj.__ctor then
		obj:__ctor(...)
	end

	obj.__type = name

	return obj
end

function object.getSet(name, var, def, proxy)
	metatables[name]["set" .. var] = function(self, val)
		if proxy then val = proxy(val) end
		self[var] = val
	end
	metatables[name]["get" .. var] = function(self, val)
		return self[var] or def
	end
end

function object.isSet(name, var, def, proxy)
	metatables[name]["set" .. var] = function(self, val)
		if proxy then val = proxy(val) end
		self[var] = val
	end
	metatables[name]["is" .. var] = function(self, val)
		return self[var] or def
	end
end

return object
