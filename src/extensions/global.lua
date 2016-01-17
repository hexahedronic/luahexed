local level = 3

-- goluwa tanks
local function _assertType(var, method, ...)
	local name = debug.getinfo(level, "n").name

	local types = {...}
	local allowed = ""
	local typ = method(var)

	local matched = false

	for key, expected in ipairs(types) do
		if typ == expected then
			matched = true
		end
	end

	if not matched then
		local arg = ""

		for i = 1, 32 do
			local key, value = debug.getlocal(level, i)
				-- I'm not sure what to do about this part with vars that have no reference
			if value == var then
				if #arg > 0 then
					arg = arg .. " or #" .. i
				else
					arg = arg .. "#" ..i
				end
			end

			if not key then
				break
			end
		end

		local allowed = ""

		for key, expected in ipairs(types) do
			if #types ~= key then
				allowed = allowed .. expected .. " or "
			else
				allowed = allowed .. expected
			end
		end

		error(("bad argument %s to '%s' (%s expected, got %s)"):format(arg, name, allowed, typ), level + 1)
	end
end

local idx = function(var) return var[0] end
function hasindex(var)
	local T = type(var)

	if T == "string" then
		return false
	end

	if T == "table" then
		return true
	end

	if not pcall(idx, var) then return false end

	local meta = getmetatable(var)

	if meta == "ffi" then return true end

	T = type(meta)

	return T == "table" and meta.__index ~= nil
end


function typex(i)

	if hasindex(i) then
		
		local t = i.__type

		if isfunction(t) then t = t() end

		return t or type(i)

	end 

	return type(i)

end

function assertType(v, ...)
	_assertType(v, typex, ...)
end

function assertTypeSimple(v, ...)
	_assertType(v, type, ...)
end

local function v(t) return function(a) return type(a) == t end end

isstring = v("string")
isnumber = v("number")
istable = v("table")
isfunction = v("function")

	isboolean = v("boolean")
	isbool = isboolean -- for gmod faggers who wanna use isbool

isuserdata = v("userdata")

isany = function(a, ...)
	for i = 1, select("#", ...) do
		
		local v = select(i, ...)

		if type(a) == v then return true end

	end
	return false
end
