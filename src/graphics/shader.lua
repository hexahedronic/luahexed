local ffi = require("ffi")

local shader = {}
local shaders = {}

function shader.use(name)
	if not shaders[name] or not shaders[name]:isValid() then
		error("OpenGL -> Attempt to use non-existant, or unlinked shader -> " .. name)
	end
	gl.glUseProgram(shaders[name].program)
end

function shader.destroyAll()
	for name, shade in pairs(shaders) do
		if shade:isValid() then shader:__gc() end
	end
end

function shader:__ctor(name)
	assertType(name, "string")

	self.program = gl.glCreateProgram()
	self.shaders = {}
	self.name = name

	if shaders[name] then
		error("OpenGL -> Attempt to re-define a shader!")
	end
	shaders[name] = self
end

function shader:__gc()
	self:setValid(false)
	if self.program then
		gl.glDeleteProgram(self.program)
	end
	if self.shaders then
		for shaderType, shade in pairs(self.shaders) do
			gl.glDeleteShader(shade)
		end
	end
	shaders[self.name] = nil
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

		self:__gc()
		error(ffi.string(buffer))
	end
	self.shaders[shaderType] = shade
end

function shader:bindFrag(position, name)
	gl.glBindFragDataLocation(self.program, position, name)
end


function shader:addAttribute(position, name)
	gl.glBindAttribLocation(self.program, position, name)
end

function shader:getAttribute(name)
	return gl.glGetAttribLocation(self.program, name)
end

local floatSize = ffi.sizeof("float")
function shader:vertexAttrib(position, count, stride, size)
	local glStride = stride * floatSize
	local glSize = ffi.cast("void*", size * floatSize)

	gl.VertexAttribPointer(position, count, gl.e.FLOAT, gl.e.FALSE, glStride, glSize)
	gl.EnableVertexAttribArray(position)
end

function shader:linkProgram()
	for shaderType, shade in pairs(self.shaders) do
		gl.glAttachShader(self.program, shade)
	end
	gl.glLinkProgram(self.program)

	local status = ffi.new("GLint[1]")
	gl.glGetProgramiv(self.program, gl.e.LINK_STATUS, status)
	if status[0] ~= gl.e.TRUE then
		print("OpenGL -> Error linking shader programme!")

		local buffer = ffi.new("char[512]")
		gl.glGetProgramInfoLog(self.program, 512, nil, buffer)

		self:__gc()
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
