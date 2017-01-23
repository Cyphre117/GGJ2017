Menu = {}
Menu.prototype = {
	items = {},
	index = 1,
	active = false
}

function Menu:new()
	-- Create new empty object
	local o = {}
	
	-- Set the meta table
	setmetatable(o, self)
	self.__index = self

	-- Copy in default member variables
	for k,v in pairs(self.prototype) do
		o[k] = v
	end

	return o;
end

function Menu:update( dt )
end

function Menu:draw( dt )
	if self.active then
		love.graphics.setColor(255, 255, 255, 255)
		for i = 1, #self.items do
			local string = self.items[i].text
			if self.index == i then
				string = "> "..string
			end
			love.graphics.print(string, 20, 120 + 30 * i, 0, 2, 2)
		end
	end
end

function Menu:selected_text()
	return self.items[self.index].text
end

function Menu:handle_input( keyboard_pressed, gamepad_pressed )

	if self.active then
		if keyboard_pressed == "up" or gamepad_pressed == "dpup" then
			-- move up the menu, wrap around at top
			self.index = self.index - 1
			if self.index < 1 then self.index = #self.items end
		elseif keyboard_pressed == "down" or gamepad_pressed == "dpdown" then
			-- move down, warp to top at the bottom
			self.index = self.index + 1
			if self.index > #self.items then self.index = 1 end
		else
			-- activate menu item
			if self.items[self.index].callback then
				self.items[self.index].callback(keyboard_pressed, gamepad_pressed)
			end
		end
	end

	-- toggle menu state
	if keyboard_pressed == "escape" or gamepad_pressed == "start" then
		self.active = not self.active
	end
end

function Menu:add_item( tag, text, callback )
	table.insert( self.items, {text=text, callback=callback} )
end