local triangle = mesh({
	 0.0,  0.5,
	 0.5, -0.5,
	-0.5, -0.5,
}) -- single triangle, no point in using elements for now

local testVertex = [[
#version 150

in vec2 position;

void main()
{
    gl_Position = vec4(position, 0.0, 1.0);
}
]]

local testFrag = [[
#version 150

out vec4 outColor;

void main()
{
    outColor = vec4(1.0, 1.0, 1.0, 1.0);
}
]]

local shade = shader("test_shader")
	shade:attachGLSL(gl.e.VERTEX_SHADER, testVertex)
	shade:attachGLSL(gl.e.FRAGMENT_SHADER, testFrag)
	shade:bindFrag(0, "outColor")
shade:linkProgram()

shader.use("test_shader")

local posAttrib = shade:getAttribute("position")
shade:vertexAttrib(posAttrib, 2, 5, 0)

local colAttrib = shade:getAttribute("color")
shade:vertexAttrib(colAttrib, 3, 5, 2)

event.listen("render2D", "test", function(dtTime)
	triangle:render()
end)
