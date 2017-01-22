 require "levels"
 require "camera"
 require "lava"
 require "zombie"

local window_width, window_height = love.graphics.getDimensions()
Physics:init()
player:init( Physics.world )
love.math.setRandomSeed(love.timer.getTime())

local walls = {}
local lavas = {}
local zombies = {}
local bounds = {}
local draw_world = false
local level_start_time = 0
local level_time_taken = 0
local level_filepath = ""				-- path to the image data for the level
local level_list = {}					-- array of all .png images in the image folder
local level_index = 1					-- index of the currently selected level
local loaded_level = level_filepath		-- name of the last level that was loaded
paused = false
pause_menu_list = {"restart", "levels", "controls", "credits"}
pause_menu_item = 1

function love.load()
	level_list = get_level_list()

	level_filepath = "levels/"..level_list[level_index]

	restart()
end

function love.update( dt )

	-- Player
	player:update(dt, paused)

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

function love.draw()
	-- Start Rendering world
	camera:set()
	camera:trackPlayer(player, window_width, window_height)

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
	love.graphics.rectangle("fill", bounds.minx, bounds.miny - window_height, -1000, (bounds.maxy - bounds.miny) + window_height*2)
	love.graphics.rectangle("fill", bounds.maxx, bounds.miny - window_height,  1000, (bounds.maxy - bounds.miny) + window_height*2)
	love.graphics.rectangle("fill", bounds.minx, bounds.miny, (bounds.maxx - bounds.minx), -1000)
	love.graphics.rectangle("fill", bounds.minx, bounds.maxy, (bounds.maxx - bounds.minx), 1000)

	--- Zombies
	draw_zombie_pulses()

	if draw_world then
		love.graphics.setColor( 0, 200, 0, 255 )
	else
		love.graphics.setColor( 0, 0, 0, 255 )
	end

	for i=1, #zombies do
		zombies[i]:draw()
	end

	--- Player
	player:draw()

	-- Finished rendering world
	camera:unset()

	-- Now render the HUD
	if player.dead then paused = true end

	if paused then
		love.graphics.setColor(0, 0, 0, 100)
		love.graphics.rectangle("fill", 0, 0, window_width, window_height)

		love.graphics.setColor(255, 0, 0, 100)
		love.graphics.setColor(255, 255, 255, 255)
		for i = 1, # pause_menu_list do
			local pre = "  "
			if i == pause_menu_item then pre = "> " end
			if pause_menu_list[i] == "levels" then
				love.graphics.print(pre.."level: "..GetFileName(level_filepath), 20, 120 + 30 * i, 0, 2, 2)
			else
				love.graphics.print(pre..pause_menu_list[i], 20, 120 + 30 * i, 0, 2, 2)
			end
		end

		if pause_menu_list[pause_menu_item] == "levels" then
			love.graphics.print("You can even create your own levels!\nJust add '.png' files to the levels folder\n\n100% RED = lava\n100% GREEN = zombies\n100% BLUE = player\n100% BLACK = walls", 20, 300, 0, 2, 2)
		elseif pause_menu_list[pause_menu_item] == "controls" then
			love.graphics.print("ARROWS: move\nSPACE: sonar\nR: restart\n\nZombies run towards noise\nLava kills everything", 20, 300, 0, 2, 2)
		elseif pause_menu_list[pause_menu_item] == "credits" then
			love.graphics.print(
[[Concept/Programming: Tom
@HopeThomasj

Audio: Chris
linkedin.com/in/christopher-quinn-sound

More levels by Bogdan, Sam A. and Sam C.

And thanks to Dundee Makerspace for the awesome jam site!
]], 20, 300, 0, 1.5, 1.5)
		end
	end

	player:draw_hud()
	if not player.dead and #zombies == 0 then
		-- you won the game
		paused = true

		if level_start_time > 0 then
			level_time_taken = love.timer.getTime() - level_start_time
			level_start_time = 0
		end

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print("YOU KILLED EVERYTHING", 20, 20, 0, 4, 4)
		love.graphics.print("Time: "..string.format("%.2f", level_time_taken), 20, 80, 0, 2, 2)
	end
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

function restart()
	clear_level()
	walls, lavas, zombies, bounds, level_start_time = createLevelFromImage(level_filepath)
	loaded_level = level_filepath
end

function love.keypressed( keycode, scancode, isrepeat )
	if scancode == "space" and not paused then
		player:pulse(Physics.world)
	end

	if paused then
		if scancode == "up" then

			-- move index up the menu
			pause_menu_item = pause_menu_item - 1
			if pause_menu_item < 1 then pause_menu_item = #pause_menu_list end

		elseif scancode == "down" then

			-- move index down the menu
			pause_menu_item = pause_menu_item + 1
			if pause_menu_item > #pause_menu_list then pause_menu_item = 1 end

		elseif scancode == "right" and pause_menu_list[pause_menu_item] == "levels" then

			-- change selected level
			level_index = level_index + 1
			if level_index > #level_list then level_index = 1 end
			level_filepath = "levels/"..level_list[level_index]

		elseif scancode == "left" and pause_menu_list[pause_menu_item] == "levels" then

			-- change selected level
			level_index = level_index - 1
			if level_index < 1 then level_index = #level_list end
			level_filepath = "levels/"..level_list[level_index]

		end
	end

	if scancode == "r" or (paused and pause_menu_list[pause_menu_item] == "restart" and scancode == "return") then
		restart()
		paused = false

	-- enable the menu with either enter or escape
	elseif not paused and (scancode == "escape" or scancode == "return") then
		-- update the level list to check for new levels
		level_list = get_level_list()
		paused = true

	-- disable the menu with either return or escape, provided restart is not selected
	elseif paused and (scancode == "escape" or scancode == "return") then

		paused = false
		pause_menu_item = 1

		-- if the user change the level, reload it
		if loaded_level ~= level_filepath then
			restart()
		end
	end
end