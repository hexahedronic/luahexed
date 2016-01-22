local ffi = require("ffi")
local bit = require("bit")

local window = {windows = {}}

function window:__gc()
	if self.context then
		glfw.glfwDestroyWindow(self.context)
		self.context = nil
	end
	window.windows[self.id] = nil
	self:setValid(false)
end

function window:close()
	self:__gc()
end

function window:isValid()
	return self.valid
end

function window:__ctor(width, height, title, version, fullscreen, vsync, versionFallbacks)
	if width then assertType(width, "number") end
	if height then assertType(height, "number") end
	if title then assertType(title, "string") end
	if version then assertType(version, "number") end
	if fullscreen then assertType(fullscreen, "boolean") end
	if vsync then assertType(vsync, "boolean") end
	if versionFallbacks then assertType(versionFallbacks, "table") assertType(versionFallbacks[1], "number") end

	self.width 			= width or 1024
	self.height 		= height or 600
	self.title 			= title or "LuaHexed"
	self.fullscreen	= fullscreen or false
	self.vsync			= vsync or false

	self.dtTime			= 0

	self.preferedVersion 		= version or 4.4
	self.acceptableVersions	= versionFallbacks or {4.0, 3.3, 2.1, 1.2}

	local pass = self:createContext()
	if not pass then return end

	local id = #window.windows+1
	window.windows[id] = self
	self.id = id
end

function window:render(dtTime)
	assertType(dtTime, "number")

	if self:shouldClose() then
		self:close()
	else
		self:clear()
			render.call(self)
		self:pollEvents()
		self:swapBuffers()

		self.dtTime = dtTime
	end
end

function window:update()
	if not self.context then
		error("Window -> Calling update pre-context!")
	end
	glfw.glfwSetWindowTitle(self.context, self.title .. " | " .. self:getContextVersionString() .. " | " .. self:getFPS() .. " fps")
end

function window:getFPS()
	if self.dtTime <= 0 then return 0 end
	return math.floor(1 / self.dtTime)
end

function window:getContextVersionString()
	return string.format("OpenGL %s.%s.%s", self:contextVersion())
end

function window:contextVersion()
	local major 		= glfw.glfwGetWindowAttrib(self.context, glfw.CONTEXT_VERSION_MAJOR)
	local minor 		= glfw.glfwGetWindowAttrib(self.context, glfw.CONTEXT_VERSION_MINOR)
	local revision 	= glfw.glfwGetWindowAttrib(self.context, glfw.CONTEXT_REVISION)
	return major, minor, revision
end

function window:contextMatchVersion(ver)
	local version = ver or self.preferedVersion
	local major, minor = math.modf(version)
	minor = math.floor(minor * 10)

	glfw.glfwWindowHint(glfw.CONTEXT_VERSION_MAJOR, major)
	glfw.glfwWindowHint(glfw.CONTEXT_VERSION_MINOR, minor)

	if self.fullscreen then
		return glfw.glfwCreateWindow(self.width, self.height, self.title, glfw.glfwGetPrimaryMonitor(), nil), version
	else
		return glfw.glfwCreateWindow(self.width, self.height, self.title, nil, nil), version
	end
end

function window:createContext()
	local context, ver
	if self.preferedVersion then
		context, ver = self:contextMatchVersion()
	end
	if not context and self.acceptableVersions then
		for i = 1, #self.acceptableVersions do
			context, ver = self:contextMatchVersion(self.acceptableVersions[i])
			if context then break end
		end
	end

	if not context then
		print("Window -> Failed to create context.")
	return false end
	self:setValid(true)

	glfw.glfwMakeContextCurrent(context)
	if self.vsync then
		glfw.glfwSwapInterval(1)
	else
		glfw.glfwSwapInterval(0)
	end
	self:setMask(bit.bor(gl.e.COLOR_BUFFER_BIT, gl.e.DEPTH_BUFFER_BIT))

	self.context = context
	self:update()
	return true
end

function window:setMask(mask)
	self.mask = mask
end

function window:clear()
	gl.glClear(self.mask)
end

function window:getFramebufferSize()
	local size = ffi.new("int[2]")
	glfw.glfwGetFramebufferSize(self.context, size, size + 1)
	return size[0], size[1]
end

function window:getWindowSize()
	local size = ffi.new("int[2]")
	glfw.glfwGetWindowSize(self.context, size, size + 1)
	return size[0], size[1]
end

function window:setWindowSize(w, h)
	glfw.glfwSetWindowSize(self.context, w, h)
end

function window:getPosition()
	local pos = ffi.new("int[2]")
	glfw.glfwGetWindowPos(self.context, pos, pos + 1)
	return pos[0], pos[1]
end

function window:setPosition(x, y)
	glfw.glfwSetWindowPos(self.context, x, y)
end

function window:getContext()
	return self.context
end

function window:shouldClose()
	return glfw.glfwWindowShouldClose(self.context) ~= 0
end

function window:swapBuffers()
	glfw.glfwSwapBuffers(self.context)
end

function window:pollEvents()
	glfw.glfwPollEvents()
end

function window:waitEvents()
	glfw.glfwWaitEvents()
end

function window:postEmptyEvent()
	glfw.glfwPostEmptyEvent()
end

function window:getClipboardString()
	return ffi.string(glfw.glfwGetClipboardString(self.context))
end

function window:setClipboardString(body)
	glfw.glfwSetClipboardString(self.context, body)
end

function window:setVSync(vsync)
	self.vsync = vsync

	if vsync then
		glfw.glfwSwapInterval(1)
	else
		glfw.glfwSwapInterval(0)
	end
end

function window:onFocus()
	glfw.glfwMakeContextCurrent(self.context)
	window.current = self
end

object.register("window", window)
object.isSet("window", "Valid", false)

return window
