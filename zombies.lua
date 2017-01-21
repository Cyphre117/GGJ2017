Zombie = {}
Zombie.prototype = {}

function Zombie:new(x, y)
	-- Create new empty object
	local o = {}
	-- Set the meta table
	setmetatable(o, self)
	self.__index = self
	-- Copy in default member variables
	for k,v in pairs(self.prototype) do
		o[k] = v
	end
end

function Zombie:update( dt )

end

function Zombie:draw()

end