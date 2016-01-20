function main()
	-- coroutines per window
	local win = window()
	win:update()

	for i = 1, 2^14 do win:render() end

	win:destroy()
end

return main
