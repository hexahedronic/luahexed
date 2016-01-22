local render = {}

function render.glHasVersion(version, window)
	local major, minor = math.modf(version)
	minor = math.floor(minor * 10)

	local win = window or window.getCurrentWindow()
	if not win:isValid() then return false end
	local ma, mi, _ = win:contextVersion()

	if ma < major then return false end
	if ma > major then return true end

	if mi < minor then return false end
	return true
end

function render.setPrimaryWindow(win)
	render.primaryWindow = win
end

function render.getPrimaryWindow()
	return render.primaryWindow
end

function render.getWindow()
	return window.current
end

function render.setWindow(win)
	win:onFocus()
end

function render.getWindows()
	return next, window.windows
end

function render.closeAllWindows()
	for id, win in render.getWindows() do
		win:close()
	end
end

function render.set3D(enabled)
	if enabled then
		gl.glEnable(gl.e.DEPTH_TEST)
		gl.glDepthMask(1)
		gl.glDepthFunc(gl.e.LESS)
	else
		gl.glDisable(gl.e.DEPTH_TEST)
		gl.glDepthMask(0)
	end
end

function render.call(window)
	render.set3D(true)
		event.call("pre_render3D")
			event.call("render3D", game.dtTime)
		event.call("post_draw3D")
	render.set3D(false)
		event.call("pre_render2D")
			event.call("render2D", game.dtTime)
		event.call("post_render2D")
end

return render
