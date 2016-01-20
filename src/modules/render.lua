local render = {}

function render.addRenderEvent(obj, window)
	-- not tonight, but tommorow probably
	-- adding a renderhook should asign listen for
	-- 'render' from the window that was active when
	-- called, or the supplied argument
	-- when recieved call 'render' on obj as a metamethod.
end

function render.addShader(shaderType, glslCode)
	local cString = ffi.new("const char*", glslCode)
	local shader = gl.glCreateShader(shaderType)
	gl.glShaderSource(shader, 1, cString, nil)
	gl.glCompileShader(shader)

	local status = ffi.new("GLint[1]")
	gl.glGetShaderiv(shader, gl.e.COMPILE_STATUS, status)
	if status[0] ~= gl.e.TRUE then
		error("OpenGL -> Error creating shader!")
	end
	return shader
end

return render
