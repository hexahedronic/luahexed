function update(frame, frametime)
	render.setFrame(frame)
	render.setFrameTime(frametime)

	event.call("update")
	event.call("preRender")

	render.setContext(render.context.context_unknown)
	graphics.gl.glClear(bit.bor(graphics.glc.GL_COLOR_BUFFER_BIT, graphics.glc.GL_DEPTH_BUFFER_BIT))

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

	graphics.window:swapBuffers()
	graphics.lq_glfw.pollEvents()
end

function main()
	local okay, err = true, ""
	local frame = 0
	local lastframe = 0

	repeat
		local time = graphics.lq_glfw.getTime()
		local frametime = time - lastframe

		frame = frame + 1
		lastframe = time

		okay, err = pcall(update, frame, frametime)

		if not okay then
			print("error in update:" .. err)
		end
	until not okay or event.call("shouldShutdown")
end

return main
