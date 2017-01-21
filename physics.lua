local world_scale
local world

function createPhysicsWorld()
	world_scale = 10
	world = love.physics.newWorld( 0, 0, true )

	return world, world_scale
end

function createPhysicsWall( x, y, w, h )
	wall = {}
	wall.w = w
	wall.h = h
	wall.body = love.physics.newBody( world, x, y, "static" )
	wall.shape = love.physics.newRectangleShape( wall.w, wall.h )
	wall.fixture = love.physics.newFixture( wall.body, wall.shape, 0 )
	wall.fixture:setRestitution(0)

	return wall
end

function createPhysicsBox( x, y, w, h, density, restitution, type )
	box = {}
	box.w = w
	box.h = h
	box.body = love.physics.newBody( world, x, y, type )
	box.shape = love.physics.newRectangleShape( box.w, box.h )
	box.fixture = love.physics.newFixture( box.body, box.shape, density )
	box.fixture:setRestitution(restitution)

	return box
end

-- Does not handle rotation!
function drawPhysicsBox( box )
	love.graphics.rectangle("fill", box.body:getX() - box.w/2, box.body:getY() - box.h/2, box.w, box.h )
end

function createPhysicsBall( x, y, radius, density, restitution, type )
	ball = {}
	ball.radius = radius
	ball.body = love.physics.newBody( world, x, y, type )
	ball.shape = love.physics.newCircleShape( ball.radius )
	ball.fixture = love.physics.newFixture( ball.body, ball.shape, density )
	ball.fixture:setRestitution(restitution)

	return ball
end

function drawPhysicsBall( ball )
	love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.radius )
end