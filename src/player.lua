require "pulse"
require "helpers"

Player = {}
Player.prototype = {
	dead = false,
	size = 10,
	speed = 100,
	left_foot = true,				-- To keep track of alternating foot sounds
	step_speed = 1/2,				-- steps per second
	pulse_array = {},
	step_timer = 0,
	pulse_sounds = {},
	left_foot_sounds = {},
	right_foot_sounds = {},
	zombie_death_sounds = {},
	lava_death_sound = nil,
	zombie_death_text = {},
	lava_death_text = {},
	death_text = ""
}

function Player:new( world )
	
	-- Create new empty object
	local o = {}
	
	-- Set the meta table
	setmetatable(o, self)
	self.__index = self

	-- Copy in default member variables
	for k,v in pairs(self.prototype) do
		o[k] = v
	end

	o.body = love.physics.newBody( world, 0, 0, "dynamic" )
	o.shape = love.physics.newCircleShape( o.size )
	o.fixture = love.physics.newFixture( o.body, o.shape, 1 )
	o.fixture:setRestitution(0)
	o.fixture:setUserData({tag="player"})
	o.world = world	  							-- the physics world

	-- Set orientation to looking up
	love.audio.setOrientation(0, 1, 0, 0, 0, 1)

	-- load zombie death text
	for line in love.filesystem.lines("text/dead_by_zombie.txt") do
	  table.insert(o.zombie_death_text, line)
	end

	-- load lava death text
	for line in love.filesystem.lines("text/dead_by_lava.txt") do
	  table.insert(o.lava_death_text, line)
	end

	--- Load the sounds
	-- left foot sounds
	load_sounds( o.left_foot_sounds, "audio/Footsteps/", {
		"Left_Foot_Player_Walk_01.wav",
		"Left_Foot_Player_Walk_02.wav",
		"Left_Foot_Player_Walk_03.wav",
		"Left_Foot_Player_Walk_04.wav",
		"Left_Foot_Player_Walk_05.wav"
		} )

	load_sounds( o.right_foot_sounds, "audio/Footsteps/", {
		"Right_Foot_Player_Walk_01.wav",
		"Right_Foot_Player_Walk_02.wav",
		"Right_Foot_Player_Walk_03.wav",
		"Right_Foot_Player_Walk_04.wav",
		"Right_Foot_Player_Walk_05.wav"
		} )

	load_sounds( o.pulse_sounds, "audio/Sonar/", {
		"Sonar_Player_01.wav",
		"Sonar_Player_02.wav",
		"Sonar_Player_03.wav"
		} )

	load_sounds( o.zombie_death_sounds, "audio/Player Death/", {
		"Player_Death_Zombie_01.wav",
		"Player_Death_Zombie_02.wav",
		"Player_Death_Zombie_03.wav"
		} )

	-- death sounds
	o.lava_death_sound = love.audio.newSource("audio/Player Death/Player_Death_Lava.wav")
	o.lava_death_sound:setVolume(0.5)
	for i = 1, #o.zombie_death_sounds do
		o.zombie_death_sounds[i]:setVolume(0.5)
	end

	for i = 1, #o.pulse_sounds do
		o.pulse_sounds[i]:setVolume(0.4)
	end

	return o
end

function Player:setPosition( x, y )
	self.body:setPosition( x, y )
end

function Player:x()
	return self.body:getX()
end

function Player:y()
	return self.body:getY()
end

function Player:update(dt, paused, directions)

	local x_vel = 0
	local y_vel = 0

	if self.dead == false and paused == false then

		x_vel = self.speed * directions.x_axis
		y_vel = self.speed * directions.y_axis

		-- Create footsteps when you walk
		if x_vel ~= 0 or y_vel ~= 0 then
			self.step_timer = self.step_timer + dt
		else
			self.step_timer = self.step_speed
		end
	end

	self.body:setLinearVelocity( x_vel, y_vel )

	-- Set the players posiiton as that of the audio listener
	love.audio.setPosition(player:x(), player:y(), 0)

	-- Pulses are continously set the location of the listener
	-- Avoids weird sudden falloff when walking and using sonar
	for i = 1, #self.pulse_sounds do
		self.pulse_sounds[i]:setPosition(player:x(), player:y(), 0)
	end

	-- Play footstep soudns
	if self.step_timer > self.step_speed then
		-- The player stepped
		self.step_timer = 0
		table.insert( self.pulse_array, Pulse:new(self.world, player:x(), player:y(), 0.18, 30, 255, 255, 255) )

		local footstep_x_offset, footstep_y_offset = 0, 0
		if x_vel > 0 then footstep_x_offset = 5 elseif x_vel < 0 then footstep_x_offset = -5 end
		if y_vel > 0 then footstep_y_offset = 5 elseif y_vel < 0 then footstep_y_offset = -5 end


		self.left_foot = not self.left_foot
		if self.left_foot then
			-- have to stop playing sources other wise the wound play form the start
			-- Also set the location of the source to that of the player
			local id = love.math.random(#self.left_foot_sounds)
			self.left_foot_sounds[id]:stop()
			self.left_foot_sounds[id]:setPosition(player:x() - footstep_x_offset, player:y() - footstep_y_offset, 0)
			self.left_foot_sounds[id]:play()
		else
			local id = love.math.random(#self.right_foot_sounds)
			self.right_foot_sounds[id]:stop()
			self.right_foot_sounds[id]:setPosition(player:x() - footstep_x_offset, player:y() - footstep_y_offset, 0)
			self.right_foot_sounds[id]:play()
		end
	end

	-- update all pulses
	for i,v in ipairs(self.pulse_array) do
		if v then
			self.pulse_array[i]:update(dt)
		end
	end

	-- remove pulses that are dead
	for i = 1, #self.pulse_array do
		if self.pulse_array[i] ~= nil and self.pulse_array[i].dead == true then
			table.remove( self.pulse_array, i )
		end
	end
end

function Player:respawn()
	self.dead = false
end

function Player:die(killer)
	if not self.dead then
		self.dead = true
		if killer == "zombie" then
			-- set death text
			self.death_text = self.zombie_death_text[love.math.random(#self.zombie_death_text)]

			-- play sounds for killed by zombie
			local id = love.math.random(#self.zombie_death_sounds)
			self.zombie_death_sounds[id]:stop()
			self.zombie_death_sounds[id]:setPosition(player:x(), player:y(), 0)
			self.zombie_death_sounds[id]:play()
		elseif killer == "lava" then
			-- set death text
			self.death_text = self.lava_death_text[love.math.random(#self.lava_death_text)]

			-- play sounds for killed by lava
			self.lava_death_sound:stop()
			self.lava_death_sound:setPosition(player:x(), player:y(), 0)
			self.lava_death_sound:play()
		end

		self.pulse_array = {}
	end
end

function Player:pulse()
	if not player.dead then
		table.insert( self.pulse_array, Pulse:new(self.world, player:x(), player:y(), 2, 10, 0, 0, 255) )

		local id = love.math.random(#self.pulse_sounds)
		self.pulse_sounds[id]:stop()
		self.pulse_sounds[id]:play()
	end
end

function Player:draw()
	if not self.dead then
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.circle("fill", self:x(), self:y(), self.size )
	end
end

function Player:draw_hud()
	if self.dead then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.print(self.death_text, 20, 20, 0, 5, 5)
	end
end

function Player:draw_pulses()
	-- draw all pulses
	for i,v in ipairs(self.pulse_array) do
		self.pulse_array[i]:draw()
	end
end