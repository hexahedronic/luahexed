local vec3d = {}

function vec3d:__ctor(x, y, z)
	self:set(x, y, z)
end

function vec3d:update()
	if self.cache then
		self.cache[0] = self.x
		self.cache[1] = self.y
		self.cache[2] = self.z
	end
end

function vec3d:set(x, y, z)
	assertType(x, "number")
	assertType(y, "number")
	assertType(z, "number")

	self.x = x
	self.y = y
	self.z = z

	self:update()
end

function vec3d:getf()
	if self.cache then
		self:update()

		return self.cache
	end

	local f = util.fArray{self.x, self.y, self.z}
	self.cache = f

	return f
end

function vec3d:mul(vec)
	assertType(vec, "vec3d")

	self.x = self.x * vec.x
	self.y = self.y * vec.y
	self.z = self.z * vec.z
end

function vec3d:div(vec)
	assertType(vec, "vec3d")

	self.x = self.x / vec.x
	self.y = self.y / vec.y
	self.z = self.z / vec.z
end

function vec3d:add(vec)
	assertType(vec, "vec3d")

	self.x = self.x + vec.x
	self.y = self.y + vec.y
	self.z = self.z + vec.z
end

function vec3d:sub(vec)
	assertType(vec, "vec3d")

	self.x = self.x - vec.x
	self.y = self.y - vec.y
	self.z = self.z - vec.z
end

object.register("vec3d", vec3d)

local vec2d = {}

function vec2d:__ctor(x, y)
	self:set(x, y)
end

function vec2d:update()
	if self.cache then
		self.cache[0] = self.x
		self.cache[1] = self.y
	end
end

function vec2d:set(x, y)
	self.x = x
	self.y = y

	self:update()
end

function vec2d:getf()
	if self.cache then
		self:update()

		return self.cache
	end

	local f = util.fArray{self.x, self.y, 0}
	self.cache = f

	return f
end

function vec2d:mul(vec)
	assertType(vec, "vec2d")

	self.x = self.x * vec.x
	self.y = self.y * vec.y
end

function vec3d:div(vec)
	assertType(vec, "vec2d")

	self.x = self.x / vec.x
	self.y = self.y / vec.y
end

function vec2d:add(vec)
	assertType(vec, "vec2d")

	self.x = self.x + vec.x
	self.y = self.y + vec.y
end

function vec2d:sub(vec)
	assertType(vec, "vec2d")

	self.x = self.x - vec.x
	self.y = self.y - vec.y
end

object.register("vec2d", vec2d)

return vec3d, vec2d
