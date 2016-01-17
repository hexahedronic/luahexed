local CubeVerticies = {}
CubeVerticies.v = util.fArray{
	{0,0,1}, {0,0,0}, {0,1,0}, {0,1,1}, -- Vector(0, 0, 1), Vector(0, 0, 0), Vector(0, 1, 0), Vector(0, 1, 1)
	{1,0,1}, {1,0,0}, {1,1,0}, {1,1,1}  -- Vector(1, 0, 1), Vector(1, 0, 0), Vector(1, 1, 0), Vector(1, 1, 1)
}

CubeVerticies.n = util.fArray{
	{-1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {1.0, 0.0, 0.0},
	{0.0, -1.0, 0.0}, {0.0, 0.0, -1.0}, {0.0, 0.0, 1.0}
}

CubeVerticies.f = util.fArray{
	{0, 1, 2, 3}, {3, 2, 6, 7}, {7, 6, 5, 4},
	{4, 5, 1, 0}, {5, 6, 2, 1}, {7, 4, 0, 3}
}

local w,h = render.getSize()

graphics.glu.gluPerspective(60, w/h, 0.01, 1000) -- fov, aspect, nearclip, farclip

--graphics.gl.glMatrixMode(graphics.glc.GL_PROJECTION) -- different matrixes, not quite sure
-- setting it twice does nothing, unless i am genuinely retarded?
graphics.gl.glMatrixMode(graphics.glc.GL_MODELVIEW) -- different matrixes, not quite sure

graphics.glu.gluLookAt(0,10,20, -- eye offset
	0,0,0, -- origin
	0,1,-1) -- up vector, like in gmod-

local rotx, roty, rotz = 0, 0, 100
local boxx, boxy, boxz = -0.5,-0.5,2

event.listen("render3D", "test", function()
	--print(input.cursorPos(), render.getFPS())
	local time = render.curTime()

	-- this is like localtoworld, it moves the cube's origin
	graphics.gl.glTranslated(boxx, boxy, boxz)

	-- rotation, rotates by first arg as degrees around the vertex x,y,z
	graphics.gl.glRotated(0LL, rotx, roty, rotz)

	graphics.gl.glColor3d(0.5, 1, 0.5)
	render.drawQuad(vec3d(-100, 0, -100), vec3d(100, 0, -100), vec3d(100, 0, 100), vec3d(-100, 0, 100), vec3d(0, 1, 0))

	graphics.gl.glRotated(time^2, rotx, roty, rotz)

		graphics.gl.glTranslated(boxx, boxy, boxz - time)

	for i = 0, 5 do -- zero indexed

	-- set color as a set of 3 DOUBLES
	-- its not 3d as in 'context', its 3double(precision floats)!
		graphics.gl.glColor3d(1, 1 / i, 1 / i)

		-- mode, we are drawing quads
		graphics.gl.glBegin(graphics.glc.GL_QUADS)

		-- glNormal3fv = normal as set of 3 float values (3fv)
		-- sets quad normal vector as to tell what direction we drawing in
		graphics.gl.glNormal3fv(CubeVerticies.n[i])

		-- supply 4 vertexs for a cube
		for j = 0, 3 do -- zero indexed

			-- glNormal3fv = normal as set of 3 float values (3fv)
			-- face translation for this normal, gets what vertexts we want
			-- based on which face we are on.
			graphics.gl.glVertex3fv(CubeVerticies.v[CubeVerticies.f[i][j]])
		end

		-- end drawing quads
		graphics.gl.glEnd()
	end

	-- this is like localtoworld, it moves the cube's origin
	graphics.gl.glTranslated(boxx + 10, boxy, boxz - graphics.lq_glfw.getTime())

	-- rotation, rotates by first arg as degrees around the vertex x,y,z
	graphics.gl.glRotated(graphics.lq_glfw.getTime()^2, rotx, roty, rotz)
	for i = 0, 5 do -- zero indexed

	-- set color as a set of 3 DOUBLES
	-- its not 3d as in 'context', its 3double(precision floats)!
		graphics.gl.glColor3d(1, 1 / i, 1 / i)

		-- mode, we are drawing quads
		graphics.gl.glBegin(graphics.glc.GL_QUADS)

		-- glNormal3fv = normal as set of 3 float values (3fv)
		-- sets quad normal vector as to tell what direction we drawing in
		graphics.gl.glNormal3fv(CubeVerticies.n[i])
		for j = 0, 3 do -- zero indexed

			-- glNormal3fv = normal as set of 3 float values (3fv)
			-- face translation for this normal, gets what vertexts we want
			-- based on which face we are on.
			graphics.gl.glVertex3fv(CubeVerticies.v[CubeVerticies.f[i][j]])
		end

		-- end drawing quads
		graphics.gl.glEnd()
	end
end)
