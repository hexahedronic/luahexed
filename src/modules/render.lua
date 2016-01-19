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

function render.drawCube(w, h, d, callback)
	local data = {}

	data.vert = {
		vec3d(0,0,d), vec3d(0,0,0), vec3d(0,h,0), vec3d(0,h,d),
		vec3d(w,0,d), vec3d(w,0,0), vec3d(w,h,0), vec3d(w,h,d)
	}
	data.norm = {
		vec3d(-1,0,0), vec3d(0,1,0), vec3d(1,0,0),
		vec3d(0,-1,0), vec3d(0,0,-1), vec3d(0,0,1)
	}
	data.face = {
		{1, 2, 3, 4}, {4, 3, 7, 8}, {8, 7, 6, 5},
		{5, 6, 2, 1}, {6, 7, 3, 2}, {8, 5, 1, 4}
	}

	for f = 1, 6 do
		callback(f)

		render.drawQuad(
			data.vert[data.face[f][1]],
			data.vert[data.face[f][2]],
			data.vert[data.face[f][3]],
			data.vert[data.face[f][4]],
			data.norm[f])
	end
end

function render.getSize()
	return graphics.window:getFramebufferSize()
end

function render.shouldClose()
	return graphics.window:shouldClose()
end

event.listen("shouldShutdown", "windowClose", render.shouldClose)

return render
