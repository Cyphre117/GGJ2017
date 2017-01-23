 require "levels"
 require "camera"
 require "lava"
 require "zombie"
 require "menu"
 require "MainMenuState"
 require "PauseMenuState"
 require "PlayingState"

screen_width, screen_height = love.graphics.getDimensions()

walls = {}
lavas = {}
zombies = {}
bounds = {}
draw_world = false
level_start_time = 0
level_time_taken = 0
level_filepath = ""				-- path to the image data for the level
level_list = {}					-- array of all .png images in the image folder
level_index = 1					-- index of the currently selected level
loaded_level = level_filepath		-- name of the last level that was loaded
controller = {connection=nil, type="none", name=""}
directions = {x_axis = 0, y_axis = 0}
pause_menu = Menu:new()

active_update = function() print('no update') end
active_draw = function() print('no draw') end

current_state = PlayingState

function love.load()
	love.math.setRandomSeed(love.timer.getTime())

	pause_menu:add_item("restart", "restart", function(k, g) if k == "return" or g == "a" then restart() end end)
	pause_menu:add_item("levels", "levels", select_level)
	pause_menu:add_item("controls", "controls", nil)
	pause_menu:add_item("credits", "credits", nil)

	Physics:init()
	
	player = Player:new( Physics.world, 0, 0 )
	
	level_list = get_level_list()

	level_filepath = "levels/"..level_list[level_index]

	restart()
	select_level()

	pause_menu.active = true
	pause_menu.index = 3

	active_draw = playing_draw
end

function love.update( dt )
	current_state:update( dt )
end

function love.draw()
	active_draw()
	current_state:draw()
end

function love.joystickpressed(joystick, button)
	-- On OSX using the XBox360 drivers the controller was not recognized by love as a gamepad
	if joystick:getName() == "Xbox 360 Wired Controller" then
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
	end
end

function love.gamepadpressed(gamepad, button)

	if button == "a" and not pause_menu.active then
		player:pulse(Physics.world)
	end

	pause_menu:handle_input(nil, button)

	-- restart by pressing select
	if button == "back" and not pause_menu.active then
		restart()
	end
end

function love.keypressed( keycode, scancode, isrepeat )
	if scancode == "space" and not pause_menu.active then
		player:pulse(Physics.world)
	end

	pause_menu:handle_input(scancode, nil)

	-- Restart with the R key
	if scancode == "r" and pause_menu.active == false then
		restart()
	end
end

function love.joystickadded( joystick )
	controller.connection = love.joystick.getJoysticks()[1]
	controller.name = controller.connection:getName()

	if controller.connection:isGamepad() then
		controller.type = "gamepad"
	else
		-- the joystick isn't recognised as a gamepad, but it still might be one
		controller.type = "joystick"
	end
end

function love.joystickremoved()
	controller.connection = nil
	controller.type = "none"
	controller.name = ""
end

function love.resize( w, h )
	screen_width, screen_height = w, h
end

function for_each( table, func )
	for i=1, #table do
		table:func()
	end
end

function playing_draw()

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

function paused_update( dt )
end

function paused_draw()
end

function clear_level()
	for i = 1, #walls do
		walls[i].body:destroy()
	end
	for i = 1, #lavas do
		lavas[i].body:destroy()
	end
	for i = 1, #zombies do
		zombies[i].body:destroy()
	end
	player:respawn()
end

function GetFileName(url)
  return url:match("^.+/(.+)$")
end

function GetFileExtension(url)
  return url:match("^.+(%..+)$")
end

function get_level_list()
	local items = love.filesystem.getDirectoryItems("levels/")
	local png_files = {}

	for i = 1, #items do
		if GetFileExtension(items[i]) == ".png" then
			table.insert( png_files, items[i] )
		end
	end

	return png_files
end

function update_input()

	-- get arrow key input
	if love.keyboard.isScancodeDown("left") then
		directions.x_axis = -1
	elseif love.keyboard.isScancodeDown("right") then
		directions.x_axis = 1
	else
		directions.x_axis = 0
	end

	if love.keyboard.isScancodeDown("up") then
		directions.y_axis = -1
	elseif love.keyboard.isScancodeDown("down") then
		directions.y_axis = 1
	else
		directions.y_axis = 0
	end

	-- get controler axis input
	if controller.connection then
		if math.abs(controller.connection:getAxis(1)) > 0.2 then
			directions.x_axis = controller.connection:getAxis(1)
		end
		if math.abs(controller.connection:getAxis(2)) > 0.2 then
			directions.y_axis = controller.connection:getAxis(2)
		end
	end
end

function restart()
	clear_level()
	walls, lavas, zombies, bounds, level_start_time = createLevelFromImage(level_filepath)
	loaded_level = level_filepath
	pause_menu.active = false
end

function select_level( keyboard_pressed, gamepad_pressed )
	-- update the level list each time
	level_list = get_level_list()

	if keyboard_pressed == "right" or gamepad_pressed == "dpright" then

		-- change selected level
		level_index = level_index + 1
		if level_index > #level_list then level_index = 1 end
		level_filepath = "levels/"..level_list[level_index]

	elseif keyboard_pressed == "left" or gamepad_pressed == "dpleft" then

		-- change selected level
		level_index = level_index - 1
		if level_index < 1 then level_index = #level_list end
		level_filepath = "levels/"..level_list[level_index]


	elseif keyboard_pressed == "return" or gamepad_pressed == "a" then
		if loaded_level ~= level_filepath then
			restart()
		end
	end

	-- indicate which is the 
	pause_menu.items[2].text = "level: "..GetFileName(level_filepath)
end