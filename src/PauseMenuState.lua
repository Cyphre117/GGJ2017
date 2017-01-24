PauseMenuState = {
	active = false,
	items = {},
	current_item = 1
}

local levels_string =
[[You can even create your own levels!
Just add '.png' files to the levels folder

100% RED = lava
100% GREEN = Level.zombies
100% BLUE = player
100% BLACK = walls]]

local controls_string = 
[[ARROWS: move
SPACE: sonar
R: restart

Zombies run towards noise
Lava kills everything]]

local credits_string =
[[Concept/Programming: Tom
@HopeThomasj

Audio: Chris
linkedin.com/in/christopher-quinn-sound

More levels by Bogdan, Sam A. and Sam C.

And thanks to Dundee Makerspace for the awesome jam site!]]

function PauseMenuState:init()
	table.insert(self.items, {text="restart", callback = function()print("restart")end})
	table.insert(self.items, {text="level", callback = function()print("level")end})
	table.insert(self.items, {text="controls", callback = function()print("controls")end})
	table.insert(self.items, {text="credits", callback = function()print("credits")end})
end

function PauseMenuState:update( dt )
end

function PauseMenuState:draw()
	-- Draw the current state of play behind the pause menu
	PlayingState:draw()

	-- Draw a transparent fullscreen rectangle
	love.graphics.setColor(0, 0, 0, 100)
	love.graphics.rectangle("fill", 0, 0, screen_width, screen_height)

	-- Draw the pause menu
	love.graphics.setColor(255, 255, 255, 255)
	for i = 1, #self.items do
		local string = self.items[i].text
		if self.current_item == i then
			string = "> "..string
		end
		love.graphics.print(string, 20, 120 + 30 * i, 0, 2, 2)
	end

	love.graphics.setColor(255, 255, 255, 255)

	if self:selected() == "levels" then
		love.graphics.print(levels_string, 20, 300, 0, 2, 2)
	elseif self:selected() == "controls" then
		love.graphics.print(controls_string, 20, 300, 0, 2, 2)
		if controller.connection then
			love.graphics.print("Controller: "..controller.name, 20, screen_height - 50, 0, 2, 2)
		end
	elseif self:selected() == "credits" then
		love.graphics.print(credits_string, 20, 300, 0, 1.5, 1.5)
	end

	player:draw_hud()
	if not player.dead and #Level.zombies == 0 then

		if level_start_time > 0 then
			level_time_taken = love.timer.getTime() - level_start_time
			level_start_time = 0
		end

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("YOU KILLED EVERYTHING", 20, 20, 0, 4, 4)
		love.graphics.print("Time: "..string.format("%.2f", level_time_taken), 20, 80, 0, 2, 2)
	end
end

function PauseMenuState:selected()
	return self.items[self.current_item].text
end

function PauseMenuState:joystickpressed( joystick, button )
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

function PauseMenuState:keypressed( keycode, scancode, isrepeat )
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

function PauseMenuState:gamepadpressed( gamepad, button )
	if button == "start" then

		current_state = PlayingState

	elseif button == "dpup" then

		-- move up the menu, wrap around at top
		self.current_item = self.current_item - 1
		if self.current_item < 1 then self.current_item = #self.items end

	elseif button == "dpdown" then

		-- move down, warp to top at the bottom
		self.current_item = self.current_item + 1
		if self.current_item > #self.items then self.current_item = 1 end

	elseif button == "a" then
		if self:selected() == "restart" then
			PlayingState:restart()
		end
	elseif self.current_item == 2 and (button == "dpright" or button == "dpleft") then
		select_level(nil, button)
	end
end

function PauseMenuState:change_level()
end