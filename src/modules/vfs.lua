local vfs = vfs or {}
local fs = require("modules.fs")

vfs.mounts = {}

function vfs.getMounts(pre)
	assertType(pre, "string")
	return vfs.mounts[pre]
end

function vfs.mount(path, pre)
	assertType(path, "string")
	assertType(pre, "string")

	vfs.unmount(path)

	path = path:gsub("\\","/")
	if path:sub(1,1) == "/" then path = path:sub(2) end
	if not path:match("/$") then path = path .. "/" end

	vfs.mounts[pre:lower()] = path
end

function vfs.unmount(path)
	assertType(path, "string")

	for mk, m in pairs(vfs.mounts) do
		if m:lower() == path:lower() then
			vfs.mounts[mk] = nil
		end
	end
end

vfs.mount(E.SRC_FOLDER, "lua")

function vfs.resolveMount(p)
	local pre = p:match("^(.-):")
	local path = p:match("^.-:(.+)"):gsub("\\","/")
	if path:sub(1,1) == "/" then path = path:sub(2) end
	if vfs.mounts[pre:lower()] then
		return vfs.mounts[pre:lower()] .. path
	end
end

function vfs.files(path)

	-- baab, will complete later on
	return fs.find(path, true)

end

local META = {} -- file

function META:isValid()

	return not not self.file

end

function META:checkfile()

	if not self:isValid() then
		error("invalid file")
	end

end

function META:open(fn, mode)

	if isValid(self.file) then
		error("file already exists")
	end

	local f, e = io.open(fn, mode)

	if f then
		self.file = f
	else
		return nil, e
	end

end

function META:close()

	self:checkfile()
	self.file:close()
	self.file = nil

end

function META:read(w)

	self:checkfile()

	local r, e = self.file:read(w)

	if r then
		return r
	else
		return nil, e
	end

end

function META:readAndClose(w, regerror)

	local r, e = self:read(w)

	if not r then
		if not regerror then
			self.file:close()
		end
	else
		self.file:close()
	end

	return r, e

end

function META:write(data)

	self:checkfile()
	local r, e = self.file:write(data)

	return r, e

end

function META:writeAndClose(w, regerror)

	local r, e = self:write(w)

	if not r then
		if not regerror then
			self.file:close()
		end
	else
		self.file:close()
	end

	return r, e

end

function META:flush()

	self:checkfile()
	local r, e = self.file:flush()

	return r, e

end

function META:__ctor(f, m)

	self:open(f, m)

end

object.register("basefile", META)

function vfs.open(path, mode)

	assertType(path, "string")
	assertType(mode, "string")

	path = vfs.resolveMount(path)

	if not path then return end

	f = object.new("basefile", path, mode)

	if f:isValid() then
		return f
	end	

end

function vfs.read(path)

	assertType(path, "string")

	f = vfs.open(path, "rb")

	if f:isValid() then
		return f:readAndClose("*all")
	end

end

function vfs.load(path)

	assertType(path, "string")

	local script = vfs.read(path)

	if not script then return end

	return loadstring(script)

end

function vfs.include(path, ...)

	local stuff = vfs.load("lua:" .. path)

	if stuff then return stuff(...) end

end

return vfs
