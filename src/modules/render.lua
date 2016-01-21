local render = {}

function render.addRenderEvent(obj, window)
	-- not tonight, but tommorow probably
	-- adding a renderhook should asign listen for
	-- 'render' from the window that was active when
	-- called, or the supplied argument
	-- when recieved call 'render' on obj as a metamethod.
end

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
		gl.Disable(gl.e.DEPTH_TEST)
		gl.DepthMask(0)
	end
end

-- draw 2d after i think?
function render.call()
	render.set3D(true)
	event.call("pre_draw3D")
	event.Call("draw3D", game.dtTime)
	event.call("post_draw3D")

	render.set3D(false)
	event.call("pre_draw2D")
	event.Call("draw2D", game.dtTime)
	event.call("post_draw2D")
end

return render
