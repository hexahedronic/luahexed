local render = {}
render.context = {
	context_unknown = 0,
	context_3d			= 1,
	context_2d			= 2,
	context_3d2d		= 3,
	context_2d3d		= 3,
}

local currentMaterial = ""
local currentContext = 0
local currentFrame = 0
local currentFrameTime = 0

function render.setMaterial(path)
	assertType(path, "string")

	currentMaterial = path or ""
end

function render.getMaterial()
	return currentMaterial
end

function render.setContext(context)
	assertType(context, "number")

	currentContext = context
end

function render.getContext()
	return currentContext
end

function render.setFrame(frame)
	assertType(frame, "number")

	currentFrame = frame
end

function render.getFrame()
	return currentFrame
end

function render.setFrameTime(frametime)
	currentFrameTime = frametime
end

function render.getFrameTime()
	return currentFrameTime
end

function render.getFPS()
	return 1 / render.getFrameTime()
end

function render.curTime()
	return graphics.lq_glfw.getTime()
end

-- actual rendering
function render.drawQuad(vec1, vec2, vec3, vec4, norm)
	assertType(vec1, "vec3d")
	assertType(vec2, "vec3d")
	assertType(vec3, "vec3d")
	assertType(vec4, "vec3d")
	assertType(norm, "vec3d")

	assert(render.getContext() == render.context.context_3d)

	local v = {}
	v[0] = vec1:getf()
	v[1] = vec2:getf()
	v[2] = vec3:getf()
	v[3] = vec4:getf()

	local n = norm:getf()

	graphics.gl.glBegin(graphics.glc.GL_QUADS)

	graphics.gl.glNormal3fv(n)
	for i = 0, 3 do
		local vertex = v[i]
		graphics.gl.glVertex3fv(vertex)
	end

	graphics.gl.glEnd()

end

function render.getSize()
	return graphics.window:getFramebufferSize()
end

function render.shouldClose()
	return graphics.window:shouldClose()
end

event.listen("shouldShutdown", "windowClose", render.shouldClose)

return render
