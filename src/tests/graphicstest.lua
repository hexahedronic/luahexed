local triangle = mesh({
	 0.0,  0.5,
	 0.5, -0.5,
	-0.5, -0.5,
})

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
shade:linkProgram() -- fails to link, error message is blank?

util.printTable(shade:getShaders())

event.listen("render2D", "test", function(dtTime)
	shader.use("test_shader")
	triangle:render()
end)
