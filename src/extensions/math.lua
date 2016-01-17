function math.dist( x1, y1, x2, y2 )
	local xd = x2-x1
	local yd = y2-y1
	return math.sqrt(xd*xd + yd*yd)
end

function math.binToInt(bin)
	return tonumber(bin, 2)
end

function math.intToBin(int)

	local str = string.format("%o",int)

	local a = {
			["0"]="000",["1"]="001", ["2"]="010",["3"]="011",
        	["4"]="100",["5"]="101", ["6"]="110",["7"]="111"
		  }
	local bin = string.gsub(str, "(.)", function (d) return a[d] end)
	return bin

end

function math.clamp(a, b, c) 
	-- if you can optimize this i will <3 you 4ever :D -ghosty
	return math.min(math.min(math.max(math.min(b, c), a), math.max(c, b)), math.max(math.min(b, c), a))
end

function math.round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function math.approach(cur, target, inc)
	inc = math.abs(inc)

	if cur < target then
		return math.clamp(cur + inc, cur, target)
	elseif cur > target then
		return math.clamp(cur - inc, target, cur)
	end

	return target
end

function math.normalizeAngle(a)
	return (a + 180) % 360 - 180
end

function math.AngleDifference(a, b)

	local diff = math.normalizeAngle(a - b)
	
	if diff < 180 then
		return diff
	end
	
	return diff - 360

end

function math.approachAngle(cur, target, inc)
	local diff = math.angleDifference(target, cur)
	return math.approach(cur, cur + diff, inc)
end

function math.timeFraction(Start, End, Current)
	return (Current - Start) / (End - Start)
end

function math.remap(value, inMin, inMax, outMin, outMax)
	return outMin + (((value - inMin) / (inMax - inMin)) * (outMax - outMin))
end
