Zombie = {}
Zombie.prototype = {radius = 20}

function Zombie:new(world, x, y)
	-- Create new empty object
	local o = {}
	-- Set the meta table
	setmetatable(o, self)
	self.__index = self
	-- Copy in default member variables
	for k,v in pairs(self.prototype) do
		o[k] = v
	end

	o.body = love.physics.newBody( world, x, y, "dynamic" )
	o.shape = love.physics.newCircleShape( o.radius )
	o.fixture = love.physics.newFixture( o.body, o.shape )
	o.fixture:setUserData( "zombie" )

	return o
end

function Zombie:update( dt )

end

function Zombie:draw()
	love.graphics.setColor( 0, 200, 0, 255 )
	love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.radius)
end