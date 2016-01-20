local function startRendering(game)
	local lastTime = 0
	while true do
		local time = glfw.glfwGetTime()
		local dtTime = lastTime - time
		coroutine.resume(game, time)

		for id, win in window.getWindows() do
			if win:isValid() then win:render(dtTime) end
		end

		lastTime = time
	end
end

local function startTickRate()
	local game = coroutine.create(function(time)
		while true do
			event.call("tick")

			local time = glfw.glfwGetTime()
			local endTime = time + (1 / 66) -- tickrate
			while true do
				if endTime < time then break end
				time = coroutine.yield()
			end
		end
	end)
	return game
end

local function main()
	local game = startTickRate()
	startRendering(game)
end

return main
