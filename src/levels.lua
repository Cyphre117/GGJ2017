require "physics"
require "player"

Level = {
	walls = {},
	lavas = {},
	zombies = {}
}

function Level:load(path)
	local scale = 50

	-- walls = {}
	-- lavas = {}
	-- zombies = {}
	bounds = {minx=-(scale/2), maxx=0, miny=-(scale/2), maxy=0}

	local image = love.image.newImageData(path)

	bounds.maxx = (image:getWidth()-1)*scale + (scale/2)
	bounds.maxy = (image:getHeight()-1)*scale + (scale/2)

	for y = 0, image:getHeight()-1 do
		for x = 0, image:getWidth()-1 do
			local r, g, b, a = image:getPixel(x, y)
			if r == 0 and g == 0 and b == 0 then
				io.write('W')
				table.insert( self.walls, Physics:addWall( x * scale, y * scale, scale, scale) )
			elseif r == 255 and g == 0 and b == 0 then
				io.write('L')
				table.insert( self.lavas, Lava:new(Physics.world, x * scale, y * scale, scale, scale) )
			elseif g == 255 and r == 0 and b == 0 then
				io.write('Z')
				table.insert( self.zombies, Zombie:new(Physics.world, x * scale, y * scale) )
			elseif r == 0 and g == 0 and b == 255 then
				io.write('P')
				player:setPosition(x * scale, y * scale)
			else
				io.write(' ')
			end
		end
		io.write('\n')
	end

	return bounds, love.timer.getTime()
end