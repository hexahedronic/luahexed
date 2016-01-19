local render = {}

function render.drawQuad(vec1, vec2, vec3, vec4, norm)
	assertType(vec1, "vec3d")
	assertType(vec2, "vec3d")
	assertType(vec3, "vec3d")
	assertType(vec4, "vec3d")
	assertType(norm, "vec3d")

	local v = {}
	v[0] = vec1:getf()
	v[1] = vec2:getf()
	v[2] = vec3:getf()
	v[3] = vec4:getf()

	local n = norm:getf()
	gl.glBegin(gl.QUADS)
	gl.glNormal3fv(n)
	for i = 0, 3 do
		local vertex = v[i]
		glfw.glVertex3fv(vertex)
	end
	glfw.glEnd()
end

function render.drawCube(w, h, d, callback)
	assertType(w, "number")
	assertType(h, "number")
	assertType(d, "number")
	if callback then assertType(callback, "function") end

	local data = {}
	data.vert = {
		vec3d(0,0,d), vec3d(0,0,0), vec3d(0,h,0), vec3d(0,h,d),
		vec3d(w,0,d), vec3d(w,0,0), vec3d(w,h,0), vec3d(w,h,d)
	}
	data.norm = {
		vec3d(-1,0,0), vec3d(0,1,0), vec3d(1,0,0),
		vec3d(0,-1,0), vec3d(0,0,-1), vec3d(0,0,1)
	}
	data.face = {
		{1, 2, 3, 4}, {4, 3, 7, 8}, {8, 7, 6, 5},
		{5, 6, 2, 1}, {6, 7, 3, 2}, {8, 5, 1, 4}
	}

	for f = 1, 6 do
		callback(f)
		render.drawQuad(
			data.vert[data.face[f][1]],
			data.vert[data.face[f][2]],
			data.vert[data.face[f][3]],
			data.vert[data.face[f][4]],
			data.norm[f]
		)
	end
end

return render
