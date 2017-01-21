require "physics"

local window_width, window_height = love.graphics.getDimensions()

function createLevel1( objects_list )
	-- put some boundaries around the level
	objects_list.wall_left = Physics:addWall( 10, window_height/2, 20, window_height )
	objects_list.wall_bottom = Physics:addWall( window_width/2, window_height - 10, window_width, 20 )

	objects_list.box1 = Physics:addBox( 100, 160, 30, 30, 1, 0.3, "dynamic" )
	objects_list.box2 = Physics:addBox( 120, 120, 30, 30, 1, 0.3, "dynamic" )
	objects_list.ball1 = Physics:addBall( 130, 50, 30, 1, 0.3, "dynamic" )
end