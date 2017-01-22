-- Sounds should be a table of files names
function load_sounds( dest_array, folder, sounds )

	for i=1,#sounds do
		table.insert( dest_array, love.audio.newSource(folder..sounds[i], "static") )
	end
end