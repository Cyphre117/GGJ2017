PauseMenuState = {
	active = false,
	items = {"restart", "level", "controls", "credits"},
	current_item = 1
}

function PauseMenuState:init()
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
	pause_menu:draw()

	if pause_menu.active then
		if pause_menu:selected_text() == "levels" then
			love.graphics.print(
[[You can even create your own levels!
Just add '.png' files to the levels folder

100% RED = lava
100% GREEN = zombies
100% BLUE = player
100% BLACK = walls]], 20, 300, 0, 2, 2)
		elseif pause_menu:selected_text() == "controls" then
			love.graphics.print(
[[ARROWS: move
SPACE: sonar
R: restart

Zombies run towards noise
Lava kills everything]]
, 20, 300, 0, 2, 2)
			if controller.connection then
				love.graphics.print("Controller: "..controller.name, 20, screen_height - 50, 0, 2, 2)
			end
		elseif pause_menu:selected_text() == "credits" then
			love.graphics.print(
[[Concept/Programming: Tom
@HopeThomasj

Audio: Chris
linkedin.com/in/christopher-quinn-sound

More levels by Bogdan, Sam A. and Sam C.

And thanks to Dundee Makerspace for the awesome jam site!]]
, 20, 300, 0, 1.5, 1.5)
		end
	end

	player:draw_hud()
	if not player.dead and #zombies == 0 then
		-- you won the game
		pause_menu.active = true

		if level_start_time > 0 then
			level_time_taken = love.timer.getTime() - level_start_time
			level_start_time = 0
		end

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("YOU KILLED EVERYTHING", 20, 20, 0, 4, 4)
		love.graphics.print("Time: "..string.format("%.2f", level_time_taken), 20, 80, 0, 2, 2)
	end
end

function PauseMenuState:joystickpressed( joystick, button )
	-- FIXME: for now, just assume all joysticks have an Xbox like layout
	-- On OSX using the XBox360 drivers the controller was not recognized by love as a gamepad
	-- if joystick:getName() == "Xbox 360 Wired Controller" then
		if button == 1 and not pause_menu.active then
			player:pulse(Physics.world)
		end

		if button == 1 then pause_menu:handle_input(nil, "a") end
		if button == 9 then pause_menu:handle_input(nil, "start") end
		if button == 10 then
			pause_menu:handle_input(nil, "back")
			if not pause_menu.active then restart() end
		end
		if button == 12 then pause_menu:handle_input(nil, "dpup") end
		if button == 13 then pause_menu:handle_input(nil, "dpdown") end
		if button == 14 then pause_menu:handle_input(nil, "dpleft") end
		if button == 15 then pause_menu:handle_input(nil, "dpright") end
	-- end
end

function PauseMenuState:keypressed( keycode, scancode, isrepeat )
	if scancode == "escape" then
		self:gamepadpressed(nil, "start")
	end
end

function PauseMenuState:gamepadpressed( gamepad, button )
	if button == "start" then
		current_state = PlayingState
		print("resume")
	end
end