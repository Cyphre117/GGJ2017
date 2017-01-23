PlayingState = {
	active = false
}

function PlayingState:init()
end

function PlayingState:update(dt)
	update_input()

	pause_menu:update( dt )

	-- Player
	player:update(dt, pause_menu.active, directions)

	-- World physics
	Physics:update(dt)

	-- Zombies
	for i=1, #zombies do
		if zombies[i] ~= nil then
			zombies[i]:update(dt)
			if zombies[i].dead then
				table.remove( zombies, i )
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
	for i=1, #lavas do
		lavas[i]:draw()
	end

	--- Pulses
	love.graphics.setLineWidth( 5 )
	player:draw_pulses()

	--- Walls
	love.graphics.setColor( 0, 0, 0 )
	for i=1, #walls do
		drawPhysicsBox( walls[i] )
	end

	--- Outer boundaries
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", bounds.minx, bounds.miny - screen_height, -1000, (bounds.maxy - bounds.miny) + screen_height*2)
	love.graphics.rectangle("fill", bounds.maxx, bounds.miny - screen_height,  1000, (bounds.maxy - bounds.miny) + screen_height*2)
	love.graphics.rectangle("fill", bounds.minx, bounds.miny, (bounds.maxx - bounds.minx), -1000)
	love.graphics.rectangle("fill", bounds.minx, bounds.maxy, (bounds.maxx - bounds.minx), 1000)

	--- Zombies
	for i=1, #zombies do
		love.graphics.setLineWidth(2)
		zombies[i]:draw_pulses()
	end

	-- love.graphics.setColor(0, 0, 0, 255)
	-- for_each( zombies, Zombie.draw )
	for i=1, #zombies do
		love.graphics.setColor(0, 0, 0, 255)
		zombies[i]:draw()
	end

	--- Player
	player:draw()

	-- Finished rendering world
	camera:unset()

	-- Now render the HUD
	if player.dead then pause_menu.active = true end
end

function PlayingState:restart()
	clear_level()
	walls, lavas, zombies, bounds, level_start_time = createLevelFromImage(level_filepath)
	loaded_level = level_filepath
	pause_menu.active = false
end

function PlayingState:joystickpressed( joystick, button )
end

function PlayingState:keypressed( keycode, scancode, isrepeat )
	if scancode == "escape" then
		self:gamepadpressed(nil, "start")
	end
end

function PlayingState:gamepadpressed( gamepad, button )
	if button == "start" then
		current_state = PauseMenuState
		print("paused")
	end
end