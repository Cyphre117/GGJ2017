 require "bodies"

local window_width, window_height = love.graphics.getDimensions()
local pixels_per_meter = 64
local world = love.physics.newWorld( 0, 9*pixels_per_meter, true )
love.physics.setMeter(pixels_per_meter)

local objects = {}

objects.box = add_box( world, 10, 20, 32, 32, 1, 0.3, "dynamic" )
objects.floor = add_box( world, 0, window_height - 32, window_width, 32, 0, 0, "static" )

function love.load()
end

function love.update( dt )
	world:update(dt)
end

function love.draw()
	love.graphics.setColor( 0, 100, 100 )
	love.graphics.print("HELLO GGJ2017", 200, 200)

	love.graphics.rectangle("line", objects.box.body:getX(), objects.box.body:getY(), objects.box.w, objects.box.h )
	love.graphics.rectangle("line", objects.floor.body:getX(), objects.floor.body:getY(), objects.floor.w, objects.floor.h )
end
