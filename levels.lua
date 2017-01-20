require "physics"

local window_width, window_height = love.graphics.getDimensions()

function createLevel1( world, objects_list )
	objects_list.floor = createPhysicsBox( world, window_width / 2, window_height - 16, window_width, 32, 0, 0, "static" )
	objects_list.box1 = createPhysicsBox( world, 100, 160, 32, 32, 1, 0.3, "dynamic" )
	objects_list.box2 = createPhysicsBox( world, 120, 120, 32, 32, 1, 0.3, "dynamic" )
	objects_list.ball1 = createPhysicsBall( world, 130, 50, 32, 1, 0.3, "dynamic" )
end