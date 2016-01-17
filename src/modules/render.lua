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
	currentMaterial = path or ""
end

function render.getMaterial()
	return currentMaterial
end

function render.setContext(context)
	currentContext = context or 0
end

function render.getContext()
	return currentContext
end

function render.setFrame(frame)
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
function render.drawQuad(vec1, vec2, vec3, vec4)
	local v1 = vec1:getf()
end

function render.getSize()
	return graphics.window:getFramebufferSize()
end

function render.shouldClose()
	return graphics.window:shouldClose()
end

event.listen("shouldShutdown", render.shouldClose)

return render
