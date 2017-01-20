function createPhysicsBox( world, x, y, w, h, density, restitution, type )
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
	love.graphics.rectangle("line", box.body:getX() - box.w/2, box.body:getY() - box.h/2, box.w, box.h )
end

function createPhysicsBall( world, x, y, radius, density, restitution, type )
	ball = {}
	ball.radius = radius
	ball.body = love.physics.newBody( world, x, y, type )
	ball.shape = love.physics.newCircleShape( ball.radius )
	ball.fixture = love.physics.newFixture( ball.body, ball.shape, density )
	ball.fixture:setRestitution(restitution)

	return ball
end

function drawPhysicsBall( ball )
	love.graphics.circle("line", ball.body:getX(), ball.body:getY(), ball.radius )
end