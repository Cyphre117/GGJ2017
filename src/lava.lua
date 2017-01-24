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
	o.shape = love.physics.newRectangleShape( o.w - (o.margin * 2), o.h - (o.margin * 2) )
	o.fixture = love.physics.newFixture( o.body, o.shape )
	o.fixture:setSensor( true )
	o.fixture:setUserData({tag="lava"})

	return o
end

function Lava:draw()
	love.graphics.setColor(200 + love.math.random() * 20, 0, 0, 255)
	love.graphics.rectangle("fill",
		self.x - (self.w/2),
		self.y - (self.h/2),
		self.w,
		self.h)
end