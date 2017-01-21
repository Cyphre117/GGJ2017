Lava = {}
Lava.prototype = {margin = 10}

function Lava:new(world, x, y, width, height)
	-- Create new empty object
	local o = {}
	-- Set the meta table
	setmetatable(o, self)
	self.__index = self
	-- Copy in default member variables
	for k,v in pairs(self.prototype) do
		o[k] = v
	end

	o.x = x
	o.y = y
	o.w = width
	o.h = height

	o.body = love.physics.newBody( world, x, y, "static" )
	o.shape = love.physics.newRectangleShape( o.w, o.h )
	o.fixture = love.physics.newFixture( o.body, o.shape )
	o.fixture:setSensor( true )
	o.fixture:setUserData({tag="lava"})

	return o
end

function Lava:draw()
	love.graphics.setColor(200, 0, 0, 255)
	love.graphics.rectangle("fill", self.body:getX() - self.w/2 - self.margin, self.body:getY() - self.h/2 - self.margin, self.w + (self.margin*2), self.h + (self.margin*2))
end