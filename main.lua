 require "levels"
 require "player"
 require "camera"
 require "lava"
 require "zombie"

local window_width, window_height = love.graphics.getDimensions()
Physics:init()

local objects = {}
player:init( Physics.world )
local draw_world = true

lava1 = Lava:new(Physics.world, 200, 200, 50, 90)
zombie1 = Zombie:new(Physics.world, 400, 400)

function love.load()
	love.window.setTitle("Sounds in a Dark Room")
	createLevel1( objects )
end

function love.update( dt )
	player:update(dt)

	Physics:update(dt)
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
	lava1:draw()

	--- Pulses
	love.graphics.setLineWidth( 5 )
	player:draw_pulses()

	--- Walls
	love.graphics.setColor( 0, 0, 0 )
	drawPhysicsBox( objects.wall_left )
	drawPhysicsBox( objects.wall_bottom )
	drawPhysicsBox( objects.box1 )
	drawPhysicsBox( objects.box2 )
	drawPhysicsBall( objects.ball1 )

	--- Zombies
	zombie1:draw()

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