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

local zed = {}

function beginContact( a, b, contact )
	if (a:getUserData().tag == "lava" and b:getUserData().tag == "player") or
	   (a:getUserData().tag == "player" and b:getUserData().tag == "lava") then
	   player:die("lava")
	elseif (a:getUserData().tag == "zombie" and b:getUserData().tag == "player") then
		if not a:getUserData().this.dead then
			player:die("zombie")
		end
	elseif (a:getUserData().tag == "player" and b:getUserData().tag == "zombie") then
		if not b:getUserData().this.dead then
			player:die("zombie")
		end
	elseif (a:getUserData().tag == "lava" and b:getUserData().tag == "zombie") then
		-- lava is in the zombie
		b:getUserData().this:die()
	elseif (b:getUserData().tag == "zombie" and a:getUserData().tag == "lava") then
		-- The zombie is in lava
		b:getUserData().this:die()

	elseif (a:getUserData().tag == "zombie" and b:getUserData().tag == "pulse") then
		  	zombie_charge( a:getUserData().this, b:getUserData().this )
	elseif (a:getUserData().tag == "pulse" and b:getUserData().tag == "zombie") then
	    	zombie_charge( b:getUserData().this, a:getUserData().this )
	end
end

function endContact( a, b, contact )

end

function preSolve( a, b, contact )
	-- body
end

function postSolve( a, b, contact, normalImpulse, tangentImpulse )
	-- body
end

function zombie_charge( zed, pulse )
	zed:charge(pulse.id, pulse.x, pulse.y, pulse.lifetime - pulse.age)
end