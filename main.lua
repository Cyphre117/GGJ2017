 require "levels"
 require "camera"
 require "lava"
 require "zombie"

local window_width, window_height = love.graphics.getDimensions()
Physics:init()
player:init( Physics.world )
--love.audio.setDistanceModel("linear")

local walls = {}
local lavas = {}
local zombies = {}
local draw_world = true

walls, lavas, zombies = createLevelFromImage('images/level1.png')

function love.load()
	love.window.setTitle("Sounds in a Dark Room")

	zombies[1].moving = true
end

function love.update( dt )
	player:update(dt)

	Physics:update(dt)

	-- Zombies
	for i=1, #zombies do
		zombies[i]:update(dt)
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

	--- Zombies
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
end

function love.keypressed( keycode, scancode, isrepeat )
	if scancode == "space" then
		player:pulse(Physics.world)

	elseif scancode == "return" then
		draw_world = not draw_world
	end
end