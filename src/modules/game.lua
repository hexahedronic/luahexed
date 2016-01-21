local game = {}
game.dtTime = 0

function game.curTime()
	return glfw.glfwGetTime()
end

return game
