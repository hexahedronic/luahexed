local startTime = os.clock()

if not require("ffi") then
	error("LuaJIT/FFI module not found! luahexed requires FFI to run.")
end

do
	if jit.os ~= "Windows" then
		package.cpath = "./?.so"
		package.path = "./?.lua"
	end
end

do

	local current_dir = io.popen("cd")

	local dir = current_dir:read("*l")
	dir = dir:gsub("\\","/")

	if not dir:match("/$") then dir = dir .. "/" end

	current_dir:close()

	local ffi = require("ffi")
	if jit.os == "Windows" then
		ffi.cdef("int SetCurrentDirectoryA(const char *);")
		ffi.C.SetCurrentDirectoryA(dir .. "bin/")
	else
		ffi.cdef("int chdir(const char *);")
		ffi.C.chdir(dir .. "bin/")
	end
end

do
	_G[jit.os:upper()] 		= true
	_G[jit.arch:upper()] 	= true

	E = E or {} -- Enumerations

	local env_vars = {
		SOUND = true,
		DEBUG = true,
	}

	for key, val in pairs(env_vars) do
		if not key then key = val val = nil end

		if  _G[key] == nil  then
			if os.getenv(key) == "0" then
				_G[key] = false
			elseif os.getenv(key) == "1" then
				_G[key] = true
			else
				_G[key] = val
			end
		end
	end
end

_OLD_G = {}

local done = {[_G] = true}
local function scan(tbl, store)
	for key, val in pairs(tbl) do
		local t = type(val)

		if t == "table" and not done[val] and val ~= store then
			store[key] = store[key] or {}
			done[val] = true
			scan(val, store[key])
		else
			store[key] = val
		end
	end
end

scan(_G, _OLD_G)


do -- 5.2 compat
	local old_setmetatable = setmetatable

	function setmetatable(tbl, meta)
		if rawget(meta, "__gc") and not rawget(tbl, "__gc_proxy") then
			local proxy = newproxy(true)
			rawset(tbl, "__gc_proxy", proxy)

			debug.getmetatable(proxy).__gc = function()
				rawset(tbl, "__gc_proxy", nil)

				local new_meta = debug.getmetatable(tbl)
				if new_meta then
					local __gc = rawget(new_meta, "__gc")

					if __gc then
						__gc(tbl)
					end
				end
			end
		end

		return old_setmetatable(tbl, meta)
	end
end

do
	local function makeLoader(f)
		package.loaders[#package.loaders + 1] = f
	end

	local main
	do
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile("../src/" .. name .. ".lua") end)
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile("../src/" .. name .. "/init.lua") end)

		--	ill set this up eventually
		--	local fs = require("fs")

		--	E.BIN_FOLDER = fs.getcd():gsub("\\", "/") .. "/"
		--	E.ROOT_FOLDER = e.BIN_FOLDER:match("(.+/)(.-/)")
		--	E.SRC_FOLDER = e.ROOT_FOLDER .. "src/"
		--	E.DATA_FOLDER = e.ROOT_FOLDER .. "data/"

		-- When VFS is done, move the loading below and only use require to load vfs
		-- after vfs is loaded use vfs to load all other files after mounting paths

		ffi							= require("ffi")

		graphics 				= require("graphics_init")
		main 						= require("main_loop")

		util						= require("modules.util")

		require("extensions.global")
		require("extensions.math")
		require("extensions.string")

		object					= require("modules.object")
		event						= require("modules.event")

		render					= require("modules.render")
		input						= require("modules.input")

		vec3d, vec2d		= require("modules.vector")

		require("tests.graphicstest")

		event.call("init")
			main()
		event.call("shutdown")

		graphics.shutdown()

		if DEBUG then while true do end end
	end
end
