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
		local BASE_DIR = "../src/"
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(BASE_DIR .. name .. ".lua") end)
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(BASE_DIR .. name .. "/init.lua") end)

		local LIB_DIR = "../src/libraries/"
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(LIB_DIR .. name .. ".lua") end)
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(LIB_DIR .. name .. "/init.lua") end)

		local MOD_DIR = "../src/modules/"
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(MOD_DIR .. name .. ".lua") end)
		makeLoader(function(name) name = name:gsub("%.", "/") return loadfile(MOD_DIR .. name .. "/init.lua") end)

	--	ill set this up eventually
	--	local fs = require("fs")

	--	E.BIN_FOLDER = fs.getcd():gsub("\\", "/") .. "/"
	--	E.ROOT_FOLDER = e.BIN_FOLDER:match("(.+/)(.-/)")
	--	E.SRC_FOLDER = e.ROOT_FOLDER .. "src/"
	--	E.DATA_FOLDER = e.ROOT_FOLDER .. "data/"

	-- When VFS is done, move the loading below and only use require to load vfs
	-- after vfs is loaded use vfs to load all other files after mounting paths
		local main 			= require("main_loop")
		graphics 				= require("graphics_init")

		event						= require("event")
		render					= require("render")
		util						= require("util")

		ffi							= require("ffi")

		local CubeVerticies = {}
		CubeVerticies.v = ffi.new("const float[8][3]", {
			{0,0,1}, {0,0,0}, {0,1,0}, {0,1,1}, -- Vector(0, 0, 1), Vector(0, 0, 0), Vector(0, 1, 0), Vector(0, 1, 1)
			{1,0,1}, {1,0,0}, {1,1,0}, {1,1,1}  -- Vector(1, 0, 1), Vector(1, 0, 0), Vector(1, 1, 0), Vector(1, 1, 1)
		})

		CubeVerticies.n = ffi.new("const float[6][3]", {
			{-1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {1.0, 0.0, 0.0},
			{0.0, -1.0, 0.0}, {0.0, 0.0, -1.0}, {0.0, 0.0, 1.0}
		})

		CubeVerticies.f = ffi.new("const float[6][4]", {
			{0, 1, 2, 3}, {3, 2, 6, 7}, {7, 6, 5, 4},
			{4, 5, 1, 0}, {5, 6, 2, 1}, {7, 4, 0, 3}
		})

		local w,h = render.getSize()

		graphics.glu.gluPerspective(60, w/h, 0.01, 1000)

		graphics.gl.glMatrixMode(graphics.glc.GL_PROJECTION)
		graphics.gl.glMatrixMode(graphics.glc.GL_MODELVIEW)
		graphics.glu.gluLookAt(0,0,5,
			0,0,0,
			0,1,0)

		local rotx, roty, rotz = 0, 0, 100
		local boxx, boxy, boxz = -0.5,-0.5,2

		event.listen("render3D", "test", function()
			print(render.getFPS())

			-- start translation matrix
			graphics.gl.glPushMatrix()

			rotx, roty, rotz = math.random(1, 100), math.random(1, 100), math.random(1, 100)

			-- this is like localtoworld, it moves the cube's origin
			graphics.gl.glTranslated(boxx, boxy, boxz - graphics.lq_glfw.getTime())

			-- rotation, rotates by first arg as degrees around the vertex x,y,z
			graphics.gl.glRotated(graphics.lq_glfw.getTime()^2, rotx, roty, rotz)
			for i = 0, 5 do -- zero indexed

			-- set color as a set of 3 DOUBLES
			-- its not 3d as in 'context', its 3double(precision floats)!
				graphics.gl.glColor3d(1, 1 / i, 1 / i)

				-- mode, we are drawing quads
				graphics.gl.glBegin(graphics.glc.GL_QUADS)

				-- glNormal3fv = normal as set of 3 float values (3fv)
				-- sets quad normal vector as to tell what direction we drawing in
				graphics.gl.glNormal3fv(CubeVerticies.n[i])
				for j = 0, 3 do -- zero indexed

					-- glNormal3fv = normal as set of 3 float values (3fv)
					-- face translation for this normal, gets what vertexts we want
					-- based on which face we are on.
					graphics.gl.glVertex3fv(CubeVerticies.v[CubeVerticies.f[i][j]])
				end

				-- end drawing quads
				graphics.gl.glEnd()
			end

			-- end matrixing
			graphics.gl.glPopMatrix()
		end)

		popLoaders(n)

		main()
		graphics.shutdown()

	end

end
