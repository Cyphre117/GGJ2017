 require "levels"
 require "camera"
 require "lava"
 require "zombie"

local window_width, window_height = love.graphics.getDimensions()
Physics:init()
player:init( Physics.world )
--love.audio.setDistanceModel("linear")

local walls = {}
local lavas = {}
local zombies = {}
local draw_world = false

walls, lavas, zombies = createLevelFromImage('images/level1.png')

function love.load()
	love.window.setTitle("Sounds in a Dark Room")

	zombies[1].moving = true
end

function love.update( dt )

	player:update(dt)

	Physics:update(dt)

	-- Zombies
	for i=1, #zombies do
		if zombies[i] ~= nil then
			zombies[i]:update(dt)
			if zombies[i].dead then
				table.remove( zombies, i )
			end
		end
	end
end

function love.draw()
	-- Start Rendering world
	camera:set()
	camera:trackPlayer(player, window_width, window_height)

	-- Draw everything back to front
	--- Background
	if draw_world then
		love.graphics.setBackgroundColor( 150, 150, 150 )
	else
		love.graphics.setBackgroundColor( 0, 0, 0 )
	end
	--- Lava first
	for i=1, #lavas do
		lavas[i]:draw()
	end

	--- Pulses
	love.graphics.setLineWidth( 5 )
	player:draw_pulses()

	--- Walls
	love.graphics.setColor( 0, 0, 0 )
	for i=1, #walls do
		drawPhysicsBox( walls[i] )
	end

	--- Zombies
	draw_zombie_pulses()

	if draw_world then
		love.graphics.setColor( 0, 200, 0, 255 )
	else
		love.graphics.setColor( 0, 0, 0, 255 )
	end

	for i=1, #zombies do
		zombies[i]:draw()
	end

	--- Player
	if not player.dead then
		player:draw()
	end

	-- Finished rendering world
	camera:unset()

	love.graphics.setColor(255, 255, 255, 255)
	if player.dead then
		love.graphics.print("YOU DIED", window_width/2 - 32, window_height/2 - 64, 0, 4, 4)
	elseif #zombies == 0 then
		love.graphics.print("YOU KILLED EVERYTHING", 20, 20, 0, 4, 4)
	end

end

function love.keypressed( keycode, scancode, isrepeat )
	if scancode == "space" then
		player:pulse(Physics.world)

	elseif scancode == "return" then
		draw_world = not draw_world
	end
end