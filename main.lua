 require "levels"
 require "player"

local window_width, window_height = love.graphics.getDimensions()
local pixels_per_meter = 64
local world = love.physics.newWorld( 0, 0, true )
love.physics.setMeter(pixels_per_meter)

local objects = {}
local player = createPlayer( world, window_width/2, window_height/2 )

function love.load()
	createLevel1( world, objects )
end

function love.update( dt )
	updatePlayer()

	world:update(dt)
end

function love.draw()
	love.graphics.setColor( 0, 100, 100 )
	love.graphics.print("HELLO GGJ2017", 200, 200)

	drawPhysicsBox( objects.floor )
	drawPhysicsBox( objects.box1 )
	drawPhysicsBox( objects.box2 )
	drawPhysicsBall( objects.ball1 )
	drawPlayer()
end

function love.keypressed( keycode, scancode, isrepeat )
	if scancode == "space" then
		player.pulsing = true
	end
end