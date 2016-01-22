local ffi = require("ffi")

local shader = {}
local shaders = {}

function shader.use(name)
	if not shaders[name] or not shaders[name]:isValid() then
		error("OpenGL -> Attempt to use non-existant, or unlinked shader -> " .. name)
	end
	gl.glUseProgram(shaders[name].program)
end

function shader:__ctor(name)
	self.program = gl.glCreateProgram()
	self.shaders = {}
	self.linked = false

	if shaders[name] then
		error("OpenGL -> Attempt to re-define a shader!")
	end
	shaders[name] = self
end

function shader:__gc()
	if self.program then
		gl.glDeleteProgram(self.program)
	end
	self:setValid(false)
end

function shader:attachGLSL(shaderType, glslCode)
	local cString = ffi.new("const char *const[1]", ffi.new("const char*", glslCode))
	local shade = gl.glCreateShader(shaderType)
	gl.glShaderSource(shade, 1, cString, nil)
	gl.glCompileShader(shade)

	local status = ffi.new("GLint[1]")
	gl.glGetShaderiv(shade, gl.e.COMPILE_STATUS, status)
	if status[0] ~= gl.e.TRUE then
		print("OpenGL -> Error creating shader!")

		local buffer = ffi.new("char[512]")
		gl.glGetShaderInfoLog(shade, 512, nil, buffer)
		error(ffi.string(buffer))
	end
	self.shaders[shaderType] = shade
end

function shader:linkProgram()
	for shaderType, shade in pairs(self.shaders) do
		gl.glAttachShader(self.program, shade)
	end
	gl.glLinkProgram(self.program)

	local status = ffi.new("GLint[1]")
	gl.glGetShaderiv(self.program, gl.e.LINK_STATUS, status)
	if status[0] ~= gl.e.TRUE then
		print("OpenGL -> Error linking shader programme!")

		local buffer = ffi.new("char[512]")
		gl.glGetShaderInfoLog(self.program, 512, nil, buffer)
		error(ffi.string(buffer))
	end
	self:setValid(true)
end

function shader:getShaders()
	return self.shaders
end

object.register("shader", shader)
object.isSet("shader", "Valid", false)

return shader
