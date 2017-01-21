Physics = {}
Physics.scale = 10

function Physics:init()
	-- Initialise the box2d world
	self.world = love.physics.newWorld( 0, 0, false )
	-- set the world scale
	love.physics.setMeter(self.scale)
	-- set callbacks
	self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

-- function createPhysicsWorld()
-- 	world_scale = 10
-- 	world = love.physics.newWorld( 0, 0, true )

-- 	return world, world_scale
-- end

function Physics:update(dt)
	self.world:update(dt)
end

function Physics:addWall( x, y, w, h )
	wall = {}
	wall.w = w
	wall.h = h
	wall.body = love.physics.newBody( self.world, x, y, "static" )
	wall.shape = love.physics.newRectangleShape( wall.w, wall.h )
	wall.fixture = love.physics.newFixture( wall.body, wall.shape, 0 )
	wall.fixture:setRestitution(0)
	wall.fixture:setUserData({tag="wall"})

	return wall
end

function Physics:addBox( x, y, w, h, density, restitution, type )
	box = {}
	box.w = w
	box.h = h
	box.body = love.physics.newBody( self.world, x, y, type )
	box.shape = love.physics.newRectangleShape( box.w, box.h )
	box.fixture = love.physics.newFixture( box.body, box.shape, density )
	box.fixture:setRestitution(restitution)

	return box
end

-- Does not handle rotation!
function drawPhysicsBox( box )
	--love.graphics.rectangle("fill", box.body:getX() - box.w/2, box.body:getY() - box.h/2, box.w, box.h )
	love.graphics.polygon("fill",box.body:getWorldPoints(box.shape:getPoints()))

end

function Physics:addBall( x, y, radius, density, restitution, type )
	ball = {}
	ball.radius = radius
	ball.body = love.physics.newBody( self.world, x, y, type )
	ball.shape = love.physics.newCircleShape( ball.radius )
	ball.fixture = love.physics.newFixture( ball.body, ball.shape, density )
	ball.fixture:setRestitution(restitution)

	return ball
end

function drawPhysicsBall( ball )
	love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.radius )
end

function beginContact( a, b, contact )
	if (a:getUserData().tag == "lava" and b:getUserData().tag == "player") or
	   (a:getUserData().tag == "player" and b:getUserData().tag == "lava") then
		-- Player touched lava
		player:die()
	elseif (a:getUserData().tag == "zombie" and b:getUserData().tag == "pulse") then

		a:getUserData().this:charge(
			b:getUserData().this.id,
			b:getUserData().this.x, b:getUserData().this.y,
			b:getUserData().this.lifetime - b:getUserData().this.age + 0.1 )

	elseif (a:getUserData().tag == "pulse" and b:getUserData().tag == "zombie") then
	    
		b:getUserData().this:charge(
			a:getUserData().this.id,
			a:getUserData().this.x, a:getUserData().this.y,
			a:getUserData().this.lifetime - a:getUserData().this.age )
	end
end

function endContact( a, b, contact )
	if (a:getUserData().tag == "zombie" and b:getUserData().tag == "pulse") then
		--print('gone')
	elseif (a:getUserData().tag == "pulse" and b:getUserData().tag == "zombie") then
		--print('gone')	    
	end
end

function preSolve( a, b, contact )
	-- body
end

function postSolve( a, b, contact, normalImpulse, tangentImpulse )
	-- body
end