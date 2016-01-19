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

	graphics.gl.glTranslated(boxx, boxy, boxz)
	graphics.gl.glRotated(0LL, rotx, roty, rotz)

	graphics.gl.glColor3d(0.5, 1, 0.5)
	render.drawQuad(vec3d(-100, 0, -100), vec3d(100, 0, -100), vec3d(100, 0, 100), vec3d(-100, 0, 100), vec3d(0, 1, 0))

	graphics.gl.glRotated(time^2, rotx, roty, rotz)
	graphics.gl.glTranslated(boxx, boxy, boxz - time)

	render.drawCube(1, 1, 1, function(f)
		graphics.gl.glColor3d(1, 1 / f, 1 / f)
	end)

	graphics.gl.glTranslated(boxx + 10, boxy, boxz - graphics.lq_glfw.getTime())
	graphics.gl.glRotated(graphics.lq_glfw.getTime()^2, rotx, roty, rotz)

	render.drawCube(2, 2, 2, function(f)
		graphics.gl.glColor3d(1, 1 / f, 1 / f)
	end)
end)
