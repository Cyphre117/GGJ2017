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
--pause_menu = Menu:new()

active_update = function() print('no update') end
active_draw = function() print('no draw') end

current_state = PauseMenuState

function love.load()
	love.math.setRandomSeed(love.timer.getTime())

	MainMenuState:init()
	PlayingState:init()
	PauseMenuState:init()

	Physics:init()

	-- pause_menu:add_item("restart", "restart", function(k, g) if k == "return" or g == "a" then PlayingState:restart() end end)
	-- pause_menu:add_item("levels", "levels", select_level)
	-- pause_menu:add_item("controls", "controls", nil)
	-- pause_menu:add_item("credits", "credits", nil)

	player = Player:new( 0, 0 )
	
	level_list = get_level_list()

	level_filepath = "levels/"..level_list[level_index]

	PlayingState:restart()
	select_level()

	PauseMenuState.active = true
	PauseMenuState.index = 3
end

function love.update( dt )
	current_state:update( dt )
end

function love.draw()
	current_state:draw()
end

function love.joystickpressed(joystick, button)
	current_state:joystickpressed(joystick, button)
end

function love.gamepadpressed(gamepad, button)

	if button == "a" and not PauseMenuState.active then
		player:pulse(Physics.world)
	end

	-- pause_menu:handle_input(nil, button)

	-- restart by pressing select
	if button == "back" and not PauseMenuState.active then
		PlayingState:restart()
	end

	current_state:gamepadpressed(gamepad, button)
end

function love.keypressed( keycode, scancode, isrepeat )
	if scancode == "space" and not PauseMenuState.active then
		player:pulse(Physics.world)
	end

	-- pause_menu:handle_input(scancode, nil)

	-- Restart with the R key
	if scancode == "r" and PauseMenuState.active == false then
		PlayingState:restart()
	end

	current_state:keypressed(keycode, scancode, isrepeat)
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
			PlayingState:restart()
		end
	end

	-- indicate which is the 
	PauseMenuState.items[2].text = "level: "..GetFileName(level_filepath)
end