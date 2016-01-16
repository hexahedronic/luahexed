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

return util
