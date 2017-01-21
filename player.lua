require "pulse"

player = {dead = false, radius = 10, step_timer = 0}
player.pulse_array = {}
player.left_foot_sounds = {}
player.right_foot_sounds = {}
player.pulse_sounds = {}

function player:init( world )
	self.body = love.physics.newBody( world, 0, 0, "dynamic" )
	self.shape = love.physics.newCircleShape( self.radius )
	self.fixture = love.physics.newFixture( self.body, self.shape, 1 )
	self.fixture:setRestitution(0)
	self.fixture:setUserData({tag="player"})
	self.world = world
	self.left_foot = true

	--- Load the sounds
	-- left foot sounds
	table.insert( self.left_foot_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Player_Walk_01.wav", "static"))
	table.insert( self.left_foot_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Player_Walk_02.wav", "static"))
	table.insert( self.left_foot_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Player_Walk_03.wav", "static"))
	table.insert( self.left_foot_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Player_Walk_04.wav", "static"))
	table.insert( self.left_foot_sounds, love.audio.newSource("audio/Footsteps/Left_Foot_Player_Walk_05.wav", "static"))
	
	-- right foot sounds
	table.insert( self.right_foot_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Player_Walk_01.wav", "static"))
	table.insert( self.right_foot_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Player_Walk_02.wav", "static"))
	table.insert( self.right_foot_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Player_Walk_03.wav", "static"))
	table.insert( self.right_foot_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Player_Walk_04.wav", "static"))
	table.insert( self.right_foot_sounds, love.audio.newSource("audio/Footsteps/Right_Foot_Player_Walk_05.wav", "static"))

	-- sonar sounds
	table.insert( self.pulse_sounds, love.audio.newSource("audio/Sonar/Sonar_Player_01.wav", "static"))
	table.insert( self.pulse_sounds, love.audio.newSource("audio/Sonar/Sonar_Player_02.wav", "static"))
	table.insert( self.pulse_sounds, love.audio.newSource("audio/Sonar/Sonar_Player_03.wav", "static"))

	for i = 1, #self.pulse_sounds do
		self.pulse_sounds[i]:setVolume(0.4)
	end
end

function player:setPosition( x, y )
	self.body:setPosition( x, y )
end

function player:x()
	return self.body:getX()
end

function player:y()
	return self.body:getY()
end

function player:update(dt)

	local vel = 100
	local x_vel = 0
	local y_vel = 0

	if not self.dead then
		if love.keyboard.isScancodeDown("right") then
			x_vel = x_vel + vel
		end
		if love.keyboard.isScancodeDown("left") then
			x_vel = x_vel - vel
		end
		if love.keyboard.isScancodeDown("up") then
			y_vel = y_vel - vel
		end
		if love.keyboard.isScancodeDown("down") then
			y_vel = y_vel + vel
		end
	end

	self.body:setLinearVelocity( x_vel, y_vel )

	-- Set the players posiiton as that of the audio listener
	love.audio.setPosition(player:x(), player:y(), 0)
	-- if x_vel ~= 0 or y_vel ~= 0 then
	-- 	love.audio.setOrientation(x_vel, math.abs(-y_vel), 0, 0, 0, 1)
	-- else
		love.audio.setOrientation(0, 1, 0, 0, 0, 1)
	-- end

	-- Pulses are continously set the location of the listener
	-- Avoids weird sudden falloff when walking and using sonar
	for i = 1, #self.pulse_sounds do
		self.pulse_sounds[i]:setPosition(player:x(), player:y(), 0)
	end

	-- steps per second
	local step_speed = 1/2

	-- Create footsteps when you walk
	if love.keyboard.isScancodeDown("left", "right", "up", "down") and not self.dead then
		self.step_timer = self.step_timer + dt
	else
		self.step_timer = step_speed
	end

	if self.step_timer > step_speed then
		-- The player stepped
		self.step_timer = 0
		table.insert( self.pulse_array, Pulse:new(self.world, player:x(), player:y(), 0.15, 25, 255, 255, 255) )

		self.left_foot = not self.left_foot
		if self.left_foot then
			-- have to stop playing sources other wise the wound play form the start
			-- Also set the location of the source to that of the player
			local id = love.math.random(#self.left_foot_sounds)
			self.left_foot_sounds[id]:stop()
			self.left_foot_sounds[id]:setPosition(player:x() - x_vel/2, player:y() - y_vel/2, 0)
			self.left_foot_sounds[id]:play()
		else
			local id = love.math.random(#self.right_foot_sounds)
			self.right_foot_sounds[id]:stop()
			self.right_foot_sounds[id]:setPosition(player:x() - x_vel/2, player:y() - y_vel/2, 0)
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

function player:respawn()
	self.dead = false
end

function player:die()
	self.dead = true
end

function player:pulse()
	table.insert( self.pulse_array, Pulse:new(self.world, player:x(), player:y(), 2, 10, 0, 0, 255) )

	local id = love.math.random(#self.pulse_sounds)
	self.pulse_sounds[id]:stop()
	self.pulse_sounds[id]:play()
end

function player:draw()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.circle("fill", self:x(), self:y(), self.radius )
end

function player:draw_pulses()
	-- draw all pulses
	for i,v in ipairs(self.pulse_array) do
		self.pulse_array[i]:draw()
	end
end