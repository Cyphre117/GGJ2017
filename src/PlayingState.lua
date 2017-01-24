PlayingState = {}

function PlayingState:init()
end

function PlayingState:update(dt)
	update_input()

	-- pause_menu:update( dt )

	-- Player
	player:update(dt, directions)

	-- World physics
	Physics:update(dt)

	-- Zombies
	for i=1, #Level.zombies do
		if Level.zombies[i] ~= nil then
			Level.zombies[i]:update(dt)
			if Level.zombies[i].dead then
				table.remove( Level.zombies, i )
			end
		end
	end
end

function PlayingState:draw()

	-- Start Rendering world
	camera:set()
	camera:trackPlayer(player, screen_width, screen_height)

	-- Draw everything back to front
	--- Background
	if draw_world then
		love.graphics.setBackgroundColor( 150, 150, 150 )
	else
		love.graphics.setBackgroundColor( 0, 0, 0 )
	end
	--- Lava first
	for i=1, #Level.lavas do
		Level.lavas[i]:draw()
	end

	--- Pulses
	love.graphics.setLineWidth( 5 )
	player:draw_pulses()

	--- Zombies
	for i=1, #Level.zombies do
		love.graphics.setLineWidth(2)
		Level.zombies[i]:draw_pulses()
	end

	for i=1, #Level.zombies do
		love.graphics.setColor(0, 0, 0, 255)
		Level.zombies[i]:draw()
	end

	--- Player
	player:draw()

	Level:draw_walls()

	-- Finished rendering world
	camera:unset()

	-- Now render the HUD
	if player.dead  or #Level.zombies == 0 then
		current_state = PauseMenuState
	end
end

function PlayingState:restart()
	Level:clear()
	bounds, level_start_time = Level:load(level_filepath)
	loaded_level = level_filepath
	current_state = PlayingState
end

function PlayingState:joystickpressed( joystick, button )
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

function PlayingState:keypressed( keycode, scancode, isrepeat )
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

function PlayingState:gamepadpressed( gamepad, button )
	if button == "a" then
		player:pulse(Physics.world)
	elseif button == "start" then
		current_state = PauseMenuState
	elseif button == "back" then
	elseif button == "dpup" then
	elseif button == "dpdown" then
	elseif button == "dpleft" then
	elseif button == "dpright" then
	end
end