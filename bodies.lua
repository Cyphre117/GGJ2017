function add_box( world, x, y, w, h, density, restitution, type )
	box = {}
	box.w = w
	box.h = h
	box.body = love.physics.newBody( world, x, y, type )
	box.shape = love.physics.newRectangleShape( box.w, box.h )
	box.fixture = love.physics.newFixture( box.body, box.shape, density )
	box.fixture:setRestitution(restitution)

	return box
end