require "physics"
require "player"

Zombie = {}
Zombie.prototype = {
	target_dirx = 0,
	target_diry = 0,
	target_id = 0,
	radius = 15,
	left_walk_sounds = {},
	right_walk_sounds = {},
	sonar_sounds = {},
	death_sounds = {},
	dead = false
}

local zombie_pulse_array = {}

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
	o.move_timer = 1

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
	table.insert(o.sonar_sounds, love.audio.newSource("audio/Sonar/Sonar_Zombie_02.wav", "static"))
	table.insert(o.sonar_sounds, love.audio.newSource("audio/Sonar/Sonar_Zombie_03.wav", "static"))

	-- zombie DEATH soudns
	table.insert(o.death_sounds, love.audio.newSource("audio/DEATH/Zombie_Death_01.wav", "static"))
	table.insert(o.death_sounds, love.audio.newSource("audio/DEATH/Zombie_Death_02.wav", "static"))
	table.insert(o.death_sounds, love.audio.newSource("audio/DEATH/Zombie_Death_03.wav", "static"))

	for i = 1, #o.death_sounds do
		o.death_sounds[i]:setVolumeLimits(0.6, 1)
	end

	return o
end

function Zombie:update( dt )
	-- steps per second
	local step_speed = 1/8

	if self.charging and not self.dead then
		self.step_timer = self.step_timer + dt

		if self.step_timer > step_speed then
			self.step_timer = 0

			table.insert( zombie_pulse_array, {lifetime = 1.5, x = self.body:getX(), y = self.body:getY(), velocity=20 } )

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

	-- update all pulses
	for i,v in ipairs(zombie_pulse_array) do
		if v then
			zombie_pulse_array[i].lifetime = zombie_pulse_array[i].lifetime - dt
		end
	end

	-- remove pulses that are dead
	for i = 1, #zombie_pulse_array do
		if zombie_pulse_array[i] ~= nil and zombie_pulse_array[i].lifetime < 0 then
			table.remove( zombie_pulse_array, i )
		end
	end

	-- Reduce the move timer, affects charging and normal random movement
	self.move_timer = self.move_timer - dt

	-- Update charging behaviour
	if not self.dead then
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

				self.body:applyLinearImpulse( love.math.random() * 200 - 100, love.math.random() * 200 - 100 )

				self.move_timer = love.math.random() * 5

				-- Play a random sonar sound
				local id = love.math.random(#self.sonar_sounds)
				self.sonar_sounds[id]:stop()
				self.sonar_sounds[id]:setPosition(self.body:getX(), self.body:getY(), 0)
				self.sonar_sounds[id]:play()

				-- Add a pulse, going to use a different kind this time
				table.insert( zombie_pulse_array, {lifetime = 3, x = self.body:getX(), y = self.body:getY(), velocity=10} )
			end
		end
	end
end

function Zombie:die()
	-- Play random death sound
	local id = love.math.random(#self.death_sounds)
	self.death_sounds[id]:stop()
	self.death_sounds[id]:setPosition(self.body:getX(), self.body:getY(), 0)
	self.death_sounds[id]:play()
	self.dead = true
	self.body:destroy()
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

function draw_zombie_pulses()
	for i=1,#zombie_pulse_array do
		love.graphics.setColor(200, 0, 0, (zombie_pulse_array[i].lifetime/3) * 255 )
		love.graphics.circle("fill",
			zombie_pulse_array[i].x,
			zombie_pulse_array[i].y,
			(1.5 - zombie_pulse_array[i].lifetime) * zombie_pulse_array[i].velocity + 10 )
	end
end