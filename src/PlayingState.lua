PlayingState = {}

function PlayingState:init()
end

function PlayingState:update(dt)
	update_input()

	pause_menu:update( dt )

	-- Player
	player:update(dt, pause_menu.active, directions)

	-- World physics
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

function PlayingState:draw()
end