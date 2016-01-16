function update(frame)
	render.setContext(render.context.context_unknown)
	render.setFrame(frame)

	event.call("update")

	event.call("preRender")

	do
		render.setContext(render.context.context_3d)

		event.call("preRender3D")
		event.call("render3D")
		event.call("postRender3D")
	end

	do
		render.setContext(render.context.context_3d2d)

		event.call("preRender3D2D")
		event.call("render3D2D")
		event.call("postRender3D2D")
	end

	do
		render.setContext(render.context.context_2d)

		event.call("preRender2D")
		event.call("render2D")
		event.call("postRender2D")
	end

	event.call("postRender")
end

function main()
	local okay, err = true, ""
	local frame = 0

	repeat
		frame = frame + 1
		okay, err = pcall(update, frame)

		if not okay then
			print("error in update:" .. err)
		end
	until not okay or event.call("shouldShutdown")
end

return main
