require "physics"

Zombie = {}
Zombie.prototype = {
	target_dirx = 0,
	target_diry = 0,
	target_id = 0,
	radius = 15,
	left_walk_sounds = {},
	right_walk_sounds = {},
	sonar_sounds = {}
}

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
	o.body:setLinearDamping( 0.5 )
	o.shape = love.physics.newCircleShape( o.radius )
	o.fixture = love.physics.newFixture( o.body, o.shape )
	o.fixture:setUserData( {tag="zombie", this=o} )
	o.left_foot = true
	o.step_timer = 0
	o.charging = false
	o.move_timer = 0

	-- left foot
	table.insert(o.left_walk_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Zombie_Walk_01.wav", "static"))
	table.insert(o.left_walk_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Zombie_Walk_02.wav", "static"))
	table.insert(o.left_walk_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Zombie_Walk_03.wav", "static"))
	table.insert(o.left_walk_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Zombie_Walk_04.wav", "static"))
	table.insert(o.left_walk_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Zombie_Walk_05.wav", "static"))
	
	-- right foot
	table.insert(o.right_walk_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Zombie_Walk_01.wav", "static"))
	table.insert(o.right_walk_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Zombie_Walk_02.wav", "static"))
	table.insert(o.right_walk_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Zombie_Walk_03.wav", "static"))
	table.insert(o.right_walk_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Zombie_Walk_04.wav", "static"))
	table.insert(o.right_walk_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Zombie_Walk_05.wav", "static"))

	-- zombie 'sonar' sounds
	table.insert(o.sonar_sounds, love.audio.newSource("audio/Sonar/Sonar_Zombie_01.wav", "static"))

	return o
end

function Zombie:update( dt )
	-- steps per second
	local step_speed = 1/8

	if self.charging then
		self.step_timer = self.step_timer + dt

		if self.step_timer > step_speed then
			self.step_timer = 0
			if self.left_foot then
				local id = love.math.random(#self.left_walk_sounds)
				-- Stop the audio incaes it's already playing
				self.left_walk_sounds[id]:stop()
				-- set the source position to the zombies position
				self.left_walk_sounds[id]:setPosition(self.body:getX(), self.body:getY(), 0)
				-- Play the sounds again
				self.left_walk_sounds[id]:play()
			else
				local id = love.math.random(#self.right_walk_sounds)
				self.right_walk_sounds[id]:stop()
				self.right_walk_sounds[id]:setPosition(self.body:getX(), self.body:getY(), 0)
				self.right_walk_sounds[id]:play()
			end
		end
	else
		self.step_timer = step_speed
	end

	-- Reduce the move timer, affects charging and normal random movement
	self.move_timer = self.move_timer - dt

	-- Update charging behaviour
	if self.charging then

		if self.move_timer < 0 then
			self.move_timer = 0
			self.charging = false

			local x, y = self.body:getLinearVelocity()
			self.body:setLinearVelocity(x * 0.1, y * 0.1)
		else
			self.body:setLinearVelocity(self.target_dirx * 200, self.target_diry * 200)
		end
	else
		-- move randomly and slowly
		if self.move_timer <= 0 then
			-- move in a random direction

			self.body:applyLinearImpulse( love.math.random() * 100, love.math.random() * 100 )

			self.move_timer = love.math.random() * 5

			print('shuffle')

			-- Play a random sonar sound
		end
	end
end

function Zombie:charge(id, x, y, time)
	if id > self.target_id then
		-- Only follow the pulse if it's more recent
		self.target_id = id

		-- Set the new target properties
		self.target_dirx = x - self.body:getX()
		self.target_diry = y - self.body:getY()
		local vec_length = math.sqrt(self.target_dirx * self.target_dirx + self.target_diry * self.target_diry)
		self.target_dirx = self.target_dirx / vec_length
		self.target_diry = self.target_diry / vec_length

		self.charging = true
		self.move_timer = time
		--print('targeting: ', self.target_dirx, ' ', self.target_diry)
	end
end

function Zombie:draw()
	love.graphics.circle("fill", self.body:getX(), self.body:getY(), self.radius)
end