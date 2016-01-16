
io.write("[CORE] init\n")

local startTime = os.clock()

if not require("ffi") then

	error("FFI module not found! luahexed requires FFI to run.")

end

hexed = hexed or {}

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

	E = E or {}

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

if not _OLD_G then

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
end

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

	local function popLoaders(n)

		for i = 1, (n or 1) do

			table.remove(package.loaders)

		end

	end

	do
		local LIB_DIR = "../src/libraries/"
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(LIB_DIR .. name .. ".lua") end)
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(LIB_DIR .. name .. "/init.lua") end)

    local LIB_MOD = "../src/modules/"
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(LIB_MOD .. name .. ".lua") end)
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(LIB_MOD .. name .. "/init.lua") end)

	--	ill set this up eventually
	--	local fs = require("fs")

	--	E.BIN_FOLDER = fs.getcd():gsub("\\", "/") .. "/"
	--	E.ROOT_FOLDER = e.BIN_FOLDER:match("(.+/)(.-/)")
	--	E.SRC_FOLDER = e.ROOT_FOLDER .. "src/"
	--	E.DATA_FOLDER = e.ROOT_FOLDER .. "data/"

		require("glfw")

		popLoaders(n)

	end

end
