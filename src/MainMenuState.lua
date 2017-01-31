MainMenuState = {
	items = {"play", "options", "quit"},
	index = 1
}

function MainMenuState:init()
end

function MainMenuState:update( dt )
end

function MainMenuState:draw()
	love.graphics.setBackgroundColor(0, 0, 0, 255)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.printf("Sounds in a Dark Room", 20, screen_height*0.1, screen_width/4-20, "left", 0, 4)

	-- print each menu item
	for i = 1, #self.items do
		local text = self.items[i]
		if i == self.index then
			text = "> "..text
		end

		love.graphics.printf(text, 20, (screen_height*0.1) * (3+i), screen_width/2-20, "left", 0, 2)
	end
end

function MainMenuState:play()
	current_state = PlayingState
end

function MainMenuState:options()
	print("options", self.index)
end

function MainMenuState:quit()
	love.event.quit()
end

function MainMenuState:joystickpressed( joystick, button )
	-- FIXME: for now, just assume all joysticks have an Xbox like layout
	-- On OSX using the XBox360 drivers the controller was not recognized by love as a gamepad
	-- convert joystick to gamepad input
	if button == 1 then			self:gamepadpressed(nil, "a")
	elseif button == 9 then		self:gamepadpressed(nil, "start")
	elseif button == 10	then	self:gamepadpressed(nil, "back")
	elseif button == 12 then	self:gamepadpressed(nil, "dpup")
	elseif button == 13 then	self:gamepadpressed(nil, "dpdown")
	elseif button == 14 then	self:gamepadpressed(nil, "dpleft")
	elseif button == 15 then	self:gamepadpressed(nil, "dpright")
	end
end

function MainMenuState:keypressed( keycode, scancode, isrepeat )
	-- convert keypresset to the controller equivilent and forward
	if scancode == "return" or scancode == "space" then		self:gamepadpressed(nil, "a")
	elseif scancode == "escape" then	self:gamepadpressed(nil, "start")
	elseif scancode == "r" then			self:gamepadpressed(nil, "back")
	elseif scancode == "up" then		self:gamepadpressed(nil, "dpup")
	elseif scancode == "down" then		self:gamepadpressed(nil, "dpdown")
	elseif scancode == "left" then		self:gamepadpressed(nil, "dpleft")
	elseif scancode == "right" then		self:gamepadpressed(nil, "dpright")
	end
end

function MainMenuState:gamepadpressed( gamepad, button )
	if button == "a" then
		self[self.items[self.index]](self)
	elseif button == "start" then
	elseif button == "back" then
	elseif button == "dpup" then
		self.index = self.index - 1
		if self.index < 1 then self.index = #self.items end
	elseif button == "dpdown" then
		self.index = self.index + 1
		if self.index > #self.items then self.index = 1 end
	elseif button == "dpleft" then
	elseif button == "dpright" then
	end
end