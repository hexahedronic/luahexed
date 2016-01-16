local graphics = {}
local glfw = require("glfw")

glfw.init()

graphics.gl, graphics.glc, graphics.glu, graphics.glfw, graphics.glext = glfw.libraries()
graphics.window = glfw.Window(1024, 768, "luahexed")

graphics.window:makeContextCurrent()

function graphics.shutdown()
	graphics.window:destroy()
	glfw.terminate()
end

return graphics
