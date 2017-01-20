local player

function createPlayer( world, x, y )
	player = {}
	player.radius = 20
	player.body = love.physics.newBody( world, x, y, "dynamic" )
	player.shape = love.physics.newCircleShape( 32 )
	player.fixture = love.physics.newFixture( player.body, player.shape, 1 )
	player.fixture:setRestitution(0)

	player.pulsing = false

	return player
end

function updatePlayer()

	local vel = 300
	local x_vel = 0
	local y_vel = 0

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

	player.body:setLinearVelocity( x_vel, y_vel )
end

function drawPlayer()
	love.graphics.circle("line", player.body:getX(), player.body:getY(), player.radius )

	if player.pulsing == true then
		love.graphics.print("PING", player.body:getX() - 20, player.body:getY() - 16 )
		player.pulsing = false
	end
end