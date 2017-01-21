 require "levels"
 require "player"
 require "camera"

local window_width, window_height = love.graphics.getDimensions()
local world, world_scale = createPhysicsWorld()
love.physics.setMeter(world_scale)

local objects = {}
player:init( world )
local draw_world = true

function love.load()
	createLevel1( objects )
end

function love.update( dt )
	player:update(dt)

	world:update(dt)
end

function love.draw()
	camera:set()
	camera:trackPlayer(player, window_width, window_height)

	if draw_world then
		love.graphics.setBackgroundColor( 150, 150, 150 )
	else
		love.graphics.setBackgroundColor( 0, 0, 0 )
	end

	love.graphics.setLineWidth( 5 )
	player:draw_pulses()

	love.graphics.setColor( 0, 0, 0 )
	drawPhysicsBox( objects.wall_left )
	drawPhysicsBox( objects.wall_bottom )
	drawPhysicsBox( objects.box1 )
	drawPhysicsBox( objects.box2 )
	drawPhysicsBall( objects.ball1 )

	player:draw()

	camera:unset()
end

function love.keypressed( keycode, scancode, isrepeat )
	if scancode == "space" then
		player.pulsing = true

		player:pulse()

	elseif scancode == "return" then
		draw_world = not draw_world
	end
end