Pulse = {}
Pulse.prototype = {age = 0.0}

function Pulse:new(world, x, y, lifetime, velocity, r, g, b)
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
	o.lifetime = lifetime
	o.velocity = velocity
	o.r = r
	o.g = g
	o.b = b
	o.age = 0.0
	o.dead = false

	-- Each pulse is itself a sensor
	o.body = love.physics.newBody( world, x, y, "kinematic" )
	o.shape = love.physics.newCircleShape( 0 )
	o.fixture = love.physics.newFixture( o.body, o.shape )
	o.fixture:setSensor( true )
	o.fixture:setUserData( "pulse" )

	print("new pulse")

	return o
end

function Pulse:delete(world)

end

function Pulse:update(dt)
	if not self.dead then
		-- Increment the age
		self.age = self.age + dt
		if self.age > self.lifetime then
			self.dead = true
			self.fixture:destroy()
		else
			-- expand the size of the sensor
			self.shape:setRadius( self.age * self.velocity * 10 )
			-- then recreate the fixture
			self.fixture:destroy()
			self.fixture = love.physics.newFixture( self.body, self.shape )
			self.fixture:setSensor( true )
			self.fixture:setUserData( "pulse" )
		end
	end
end

function Pulse:draw()
	if self.dead == false then
		love.graphics.setColor( self.r, self.g, self.b, 255 - ((self.age / self.lifetime)*255) )
		love.graphics.circle("line", self.x, self.y, self.age * self.velocity * 10)
	end
end