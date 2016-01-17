local util = {}

function util.isTable(tbl)
	return type(tbl) == "table"
end

local function printTableInternal(tbl, indent, internal)
	local ind = ("\t"):rep(indent)
	print(ind .. "{")

	for index, value in pairs(tbl) do
		if util.isTable(value) then
			printTableInternal(value, indent + 1, true)
		else
			print(ind .. "\t" .. tostring(index) .. " = " .. tostring(value) .. ",")
		end
	end

	print(ind .. "}" .. (internal and "," or ""))
end

function util.printTable(tbl)
	printTableInternal(tbl, 0, false)
end

function util.fArray(tbl)
	if not util.isTable(tbl[1]) then
		return ffi.new("float[" .. #tbl .. "]", tbl)
	end

	return ffi.new("float[" .. #tbl .. "][" .. #tbl[1] .. "]", tbl)
end

return util
