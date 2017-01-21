Pulse = {}
Pulse.prototype = {age = 0.0}

function Pulse:new(x, y, lifetime, velocity, r, g, b)
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

	return o
end

function Pulse:update(dt)
	if not self.dead then
		self.age = self.age + dt
		if self.age > self.lifetime then
			self.dead = true
		end
	end
end

function Pulse:draw()
	if self.dead == false then
		love.graphics.setColor( self.r, self.g, self.b, 255 - ((self.age / self.lifetime)*255) )
		love.graphics.circle("line", self.x, self.y, self.age * self.velocity * 10)
	end
end