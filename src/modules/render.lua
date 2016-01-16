local render = {}
render.context = {
	context_unknown = 0
	context_3d			= 1,
	context_2d			= 2,
	context_3d2d		= 3,
	context_2d3d		= 3,
}

local currentMaterial = ""
local currentContext = 0

function render.setMaterial(path)
	currentMaterial = path or ""
end

function render.getMaterial()
	return currentMaterial
end

function render.setContext(context)
	currentContext = context or ""
end

function render.getContext()
	return currentContext
end

function render.getSize()
	return graphics.window:getFramebufferSize()
end

return render
