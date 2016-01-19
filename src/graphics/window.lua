local window = {}

function window:__gc()
	glfw.glfwDestroyWindow(self.context)
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

	self.preferedVersion 		= version
	self.acceptableVersions	= versionFallbacks
end

function window:update()
	glfw.glfwSetWindowTitle(self.title .. " | " .. self:getContextVersionString() .. " | fps goes here")
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
		return glfw.glfwCreateWindow(self.width, self.height, self.title, glfw.glfwGetPrimaryMonitor()), version
	else
		return glfw.glfwCreateWindow(self.width, self.height, self.title), version
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
	return end

	glfw.glfwMakeContextCurrent(context)
	if self.vsync then
		glfw.glfwSwapInterval(1)
	else
		glfw.glfwSwapInterval(0)
	end

	self.context = context
	self:update()
end

function window:enableFeature(feature)
	gl.glEnable(feature)
end

function window:disableFeature(feature)
	gl.glDisable(feature)
end

function window:setDepthFunc(name)
	gl.glDepthFunc(name)
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
end

function window:destroy()
	self:__gc()
end
window.close 			= window.destroy
window.terminate	= window.destroy

function window:tick()
	if self:shouldClose() then
		self:__gc()
	else
		self:pollEvents()
		self:update()
		self:draw()
		self:swapBuffers()
	end
end

object.register("window", window)

return window
