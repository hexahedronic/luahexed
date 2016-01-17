local graphics = {}
graphics.lq_glfw = require("libraries.glfw")

graphics.lq_glfw.init()

graphics.gl, graphics.glc, graphics.glu, graphics.glfw, graphics.glext = graphics.lq_glfw.libraries()
graphics.window = graphics.lq_glfw.Window(1024, 768, "LuaHexed")

graphics.window:makeContextCurrent()

function graphics.shutdown()
	graphics.window:destroy()
	graphics.lq_glfw.terminate()
end

graphics.gl.glClearColor(0, 0, 0.4, 0)

graphics.gl.glEnable(graphics.glc.GL_DEPTH_TEST)
graphics.gl.glDepthFunc(graphics.glc.GL_LESS)

graphics.gl.glEnable(graphics.glc.GL_CULL_FACE)
graphics.gl.glFrontFace(graphics.glc.GL_CW)

return graphics
