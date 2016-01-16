local graphics = {}
graphics.lq_glfw = require("glfw")

graphics.lq_glfw.init()

graphics.gl, graphics.glc, graphics.glu, graphics.glfw, graphics.glext = graphics.lq_glfw.libraries()
graphics.window = graphics.lq_glfw.Window(1024, 768, "luahexed")

graphics.window:makeContextCurrent()

function graphics.shutdown()
	graphics.window:destroy()
	graphics.lq_glfw.terminate()
end

return graphics
