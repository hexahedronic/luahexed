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

return render
