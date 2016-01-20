local ffi = require("ffi")

local vertexmesh = {}

function vertexmesh:__gc()
	if self.vao then
		gl.glDeleteVertexArrays(1, self.vao)
	end
	if self.vbo then
		gl.glDeleteBuffers(1, self.vbo)
	end
	if self.ebo then
		gl.glDeleteBuffers(1, self.ebo)
	end
end

function vertexmesh:__ctor(luaVertices, luaElements)
	local vao = ffi.new("GLuint[1]")
	gl.glGenVertexArrays(1, vao)
	gl.glBindVertexArray(vao[0])
	self.vao = vao

	self.vertexCount = #luaVertices
	local vertices = ffi.new("float[?]", self.vertexCount, luaVertices)
	self.vertices = vertices

	local vbo = ffi.new("GLuint[1]")
	gl.glGenBuffers(1, vbo)
	gl.glBindBuffer(GL.ARRAY_BUFFER, vbo[0])
	gl.glBufferData(GL.ARRAY_BUFFER, ffi.sizeof(vertices), vertices, gl.e.STATIC_DRAW)
	self.vbo = vbo

	if elements then
		self.elementCount = #luaElements
		local elements = ffi.new("GLuint[?]", self.elementCount, luaElements)
		self.elements = elements

		local ebo = ffi.new("GLuint[1]")
		gl.glGenBuffers(1, ebo)
		gl.glBindBuffer(gl.e.ELEMENT_ARRAY_BUFFER, ebo[0])
		gl.glBufferData(gl.e.ELEMENT_ARRAY_BUFFER, ffi.sizeof(elements), elements, gl.e.STATIC_DRAW)
		self.ebo = ebo
	end

	render.addRenderEvent(self)
end

function vertexmesh:render()
	gl.glBindVertexArray(self.vao[0])
	if self.elements then
		gl.glDrawElements(gl.e.TRIANGLES, self.elementCount, gl.e.UNSIGNED_INT, nil)
	else
		gl.glDrawArrays(gl.e.TRIANGLES, 0, self.vertexCount)
	end
end

object.register("vertexmesh", vertexmesh)

return vertexmesh
