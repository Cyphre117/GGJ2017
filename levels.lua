require "physics"
require "player"

local window_width, window_height = love.graphics.getDimensions()

function createLevel1()
	t = {}

	-- put some boundaries around the level
	table.insert( t, Physics:addWall( 10, window_height/2, 20, window_height ) )
	table.insert( t, Physics:addWall( window_width/2, window_height - 10, window_width, 20 ) )
	--table.insert( t, Physics:addWall( ) )

	return t
end

function createLevelFromImage(path)
	local scale = 50

	walls = {}
	lavas = {}
	zombies = {}
	bounds = {minx=-(scale/2), maxx=0, miny=-(scale/2), maxy=0}

	level = love.image.newImageData(path)

	bounds.maxx = (level:getWidth()-1)*scale + (scale/2)
	bounds.maxy = (level:getHeight()-1)*scale + (scale/2)

	for y = 0, level:getHeight()-1 do
		for x = 0, level:getWidth()-1 do
			local r, g, b, a = level:getPixel(x, y)
			if r == 0 and g == 0 and b == 0 then
				io.write('W')
				table.insert( walls, Physics:addWall( x * scale, y * scale, scale, scale) )
			elseif r == 255 and g == 0 and b == 0 then
				io.write('L')
				table.insert( lavas, Lava:new(Physics.world, x * scale, y * scale, scale, scale) )
			elseif g == 255 and r == 0 and b == 0 then
				io.write('Z')
				table.insert( zombies, Zombie:new(Physics.world, x * scale, y * scale) )
			elseif r == 0 and g == 0 and b == 255 then
				io.write('P')
				player:setPosition(x * scale, y * scale)
			else
				io.write(' ')
			end
		end
		io.write('\n')
	end

	return walls, lavas, zombies, bounds, love.timer.getTime()
end