require "physics"
require "player"

Level = {
	walls = {},
	lavas = {},
	zombies = {},
}

function Level:load(path)
	local scale = 50

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

function Level:draw_walls()
	-- TODO: Draw the walls and boundaries into a stencil buffer instead?
	--		 That way the walls could be drawn first and the order of other things wouldn't matter
	-- 		 Or maybe its just simpler to draw them last

	--- Walls
	love.graphics.setColor( 0, 0, 0 )
	for i=1, #self.walls do
		drawPhysicsBox( self.walls[i] )
	end

	--- Outer boundaries
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.rectangle("fill", bounds.minx, bounds.miny - screen_height, -1000, (bounds.maxy - bounds.miny) + screen_height*2)
	love.graphics.rectangle("fill", bounds.maxx, bounds.miny - screen_height,  1000, (bounds.maxy - bounds.miny) + screen_height*2)
	love.graphics.rectangle("fill", bounds.minx, bounds.miny, (bounds.maxx - bounds.minx), -1000)
	love.graphics.rectangle("fill", bounds.minx, bounds.maxy, (bounds.maxx - bounds.minx), 1000)
end

function Level:clear()
	for i = 1, #self.walls do
		self.walls[i].body:destroy()
	end
	self.walls = {}
	for i = 1, #self.lavas do
		self.lavas[i].body:destroy()
	end
	self.lavas = {}
	for i = 1, #self.zombies do
		self.zombies[i].body:destroy()
	end
	self.zombies = {}

	player:respawn()
end

function Level:list()
	local items = love.filesystem.getDirectoryItems("levels/")
	local png_files = {}

	for i = 1, #items do
		if GetFileExtension(items[i]) == ".png" then
			table.insert( png_files, items[i] )
		end
	end

	return png_files
end