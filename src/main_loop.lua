local function startRendering(tickThread)
	local lastTime = 0
	while true do
		local time = game.curTime()
		local dtTime = time - lastTime
		game.dtTime = dtTime
		coroutine.resume(tickThread, time)

		for id, win in render.getWindows() do
			if win:isValid() then win:render(dtTime) end
		end

		lastTime = time
	end
end

local function startTickRate()
	return coroutine.create(function(time)
		while true do
			event.call("tick")
			for id, win in render.getWindows() do
				if win:isValid() then win:update() end
			end

			local time = game.curTime()
			local endTime = time + (1 / 33) -- tickrate
			while true do
				if endTime < time then break end
				time = coroutine.yield()
			end
		end
	end)
end

local function main()
	local tickThread = startTickRate()
	startRendering(tickThread)
end

return main
