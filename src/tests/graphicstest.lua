local triangle = mesh({
	 0.0,  0.5,
	 0.5, -0.5,
	-0.5, -0.5,
})

local testVertex = [[
#version 150
void main(void)
{
	vec4 a = gl_Vertex;
	a.x = a.x * 0.5;
	a.y = a.y * 0.5;

	gl_Position = gl_ModelViewProjectionMatrix * a;
}
]]

local testFrag = [[
#version 150
void main (void)
{
	gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
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
