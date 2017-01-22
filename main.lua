 require "levels"
 require "camera"
 require "lava"
 require "zombie"

local window_width, window_height = love.graphics.getDimensions()
Physics:init()
player:init( Physics.world )
love.math.setRandomSeed(love.timer.getTime())

local current_level = "images/levelduracel.png"
local walls = {}
local lavas = {}
local zombies = {}
local bounds = {}
local draw_world = false
local level_start_time = 0
local level_time_taken = 0

walls, lavas, zombies, bounds = createLevelFromImage(current_level)

function love.load()
	love.window.setTitle("Sounds in a Dark Room")

	zombies[1].moving = true
end

function love.update( dt )

	player:update(dt)

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

	player:draw_hud()
	if not player.dead and #zombies == 0 then
		if level_start_time ~= 0 then
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

function love.keypressed( keycode, scancode, isrepeat )
	if scancode == "space" then
		player:pulse(Physics.world)

	elseif scancode == "return" then
		draw_world = not draw_world
	end

	if scancode == "r" then
		clear_level()
		walls, lavas, zombies, bounds = createLevelFromImage(current_level)
	end

	if keycode == "1" then
		clear_level()
		current_level = 'images/level1.png'
		walls, lavas, zombies, bounds, level_start_time = createLevelFromImage(current_level)
	elseif keycode == "2" then
		clear_level()
		current_level = 'images/level2.png'
		walls, lavas, zombies, bounds, level_start_time = createLevelFromImage(current_level)
	elseif keycode == "3" then
		clear_level()
		current_level = 'images/level3.png'
		walls, lavas, zombies, bounds, level_start_time = createLevelFromImage(current_level)
	elseif keycode == "4" then
		clear_level()
		current_level = 'images/level4.png'
		walls, lavas, zombies, bounds, level_start_time = createLevelFromImage(current_level)
	elseif keycode == "5" then
		clear_level()
		current_level = 'images/level5.png'
		walls, lavas, zombies, bounds, level_start_time = createLevelFromImage(current_level)
	end

end