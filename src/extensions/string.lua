local meta = getmetatable("")
local string = string

function meta:__index(i)
	if type(i) == "number" then
		return self:sub(i, i)
	elseif type(i) == "string" then
		return string[i]
	end
end

function meta:__call(i, ...)
	if select("#", ...) > 0 then
		if not isstring(i) then return end
		return self:gsub(i, ...)
	end

	if type(i) == "string" then
		return self:match(i)
	elseif type(i) == "table" then
		local i1, i2 = i[1], i[2]
		assert(i1, "missing param")

		if type(i1) == "number" or type(i2) == "number" then
			return self:sub(i1, i2)
		elseif type(i1) == "string" and type(i2) == "string" then
			return self:gsub(i1, i2)
		else
			error("type mismatch")
		end
	end
end

function meta:__add(i)
	if tonumber(self) and tonumber(i) then return tonumber(self) + tonumber(i) end
	return self .. i
end

function meta:__sub(i)
	if tonumber(self) and tonumber(i) then return tonumber(self) - tonumber(i) end
	return self:gsub(tostring(i):patternSafe(), "")
end

function meta:__mul(i)
	if type(i) == "number" then
		if i == 0 then return "" end
		if i < 0 then return self:rep(i):reverse() end
		return self:rep(i)
	end
end

function meta:__div(i)
	-- fixme
end

local ps = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z"
}

function string.patternSafe(str)
	return str:gsub(".", ps)
end

function string.split(str, sep, patt)
	if sep == "" then return str:toTable() end

	local tbl = {}
	local old = 1

	if not patt then sep = sep:patternSafe() end

	for start, epos in str:gmatch("()" .. sep .. "()") do
		tbl[#tbl + 1] = str:sub(old, epos)

		old = epos
	end

	tbl[#tbl + 1] = str:sub(old)

	return tbl
end

function string.comma(nu, s)
	s = s or ","
	local n = tostring(nu)

	local int, fraction = n('[-]?(%d+)([.]?%d*)')

	local minus = (nu < 0 or nu == -0) and "-" or ""

	return minus .. int:reverse():gsub("(%d%d%d)", "%1" .. s):reverse():gsub("^" .. s:patternSafe(),"") .. fraction
end

function string.niceSize(s)
	s = tonumber(s)

	if not s then return s end

	if s <= 0 then return "0 bytes" end
	if s < 1024 then return s .. " bytes" end
	if s < 1024^2 then return math.round(s / 1024^1, 2) .. " KiB" end
	if s < 1024^3 then return math.round(s / 1024^2, 2) .. " MiB" end
	if s < 1024^4 then return math.round(s / 1024^3, 2) .. " GiB" end
	if s < 1024^5 then return math.round(s / 1024^4, 2) .. " TiB" end
	if s < 1024^6 then return math.round(s / 1024^5, 2) .. " PiB" end
	if s < 1024^7 then return math.round(s / 1024^6, 2) .. " EiB" end
	if s < 1024^8 then return math.round(s / 1024^7, 2) .. " ZiB" end
	if s < 1024^9 then return math.round(s / 1024^8, 2) .. " YiB" end

	return "too much data for HDDs to handle"
end

function string.toTable(s)
	local tbl = {}

	for w in s:gmatch(".") do
		tbl[#tbl + 1] = w
	end

	return tbl
end

local js = {
	["\\"] = "\\\\",
	["\0"] = "\\x00" ,
	["\b"] = "\\b" ,
	["\t"] = "\\t" ,
	["\n"] = "\\n" ,
	["\v"] = "\\v" ,
	["\f"] = "\\f" ,
	["\r"] = "\\r" ,
	["\""] = "\\\"",
	["\'"] = "\\\'"
}

function string.javascriptSafe(str)
	str = str:gsub(".", js)

	str = str:gsub("\226\128\168", "\\\226\128\168")
	str = str:gsub("\226\128\169", "\\\226\128\169")

	return str
end

function string.getExtensionFromFilename(str)
	return str:match"%.([^%.]+)$"
end

function string.stripExtension(str)
	local i = str:match(".+()%.%w+$")
	if i then return str{1, i - 1} end
	return str
end

function string.getPathFromFilename(str)
	return str:match("^(.*[/\\])[^/\\]-$") or ""
end

function string.getFileFromFilename(str)
	return str:match("[\\/]([^/\\]+)$") or ""
end

function string.left(str, num)
	return str:sub(1, num)
end

function string.right(str, num)
	return str:sub(-num)
end

function string.trim(s, char)
	char = char or "%s"
	return s:match("^" .. char .. "*(.-)" .. char .. "*$") or s
end

function string.trimright(s, char)
	char = char or "%s"
	return s:match("^(.-)" .. char .. "*$") or s
end

function string.trimleft(s, char)
	char = char or "%s"
	return s:match("^" .. char .. "*(.+)") or s
end

function string.fullwidth(str)
	-- todo: automatic conversion of punctation?
	str = str:gsub("%.","\239\189\161")
	str = str:gsub("%!", "\239\188\129")
	str = str:gsub("%?", "\239\188\159")
	str = str:gsub("%:", "\239\188\154")
	str = str:gsub("%;", "\239\188\155")
	str = str:gsub("%<", "\239\188\156")
	str = str:gsub("%>", "\239\188\158")
	str = str:gsub("%/", "\239\188\143")
	str = str:gsub("%\\", "\239\188\188")
	str = str:gsub("%=", "\239\188\157")
	str = str:gsub("%+", "\239\188\139")
	str = str:gsub("%-", "\239\188\141")
	str = str:gsub("%@", "\239\188\160")
	str = str:gsub("%£", "\239\191\161")
	-- upper and lower to full width
	str = str:gsub("%l", function(c) return string.char(239, 189, 130 + (c:byte() - 98)) end)
	str = str:gsub("%u", function(c) return string.char(239, 188, 161 + (c:byte() - 65)) end)
	-- numbers
	str = str:gsub("%d", function(c) return string.char(239, 188, 145 + (c:byte() - 49)) end)
	return str
end
