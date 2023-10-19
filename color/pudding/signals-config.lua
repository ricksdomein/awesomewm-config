-----------------------------------------------------------------------------------------------------------------------
--                                                Signals config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local beautiful = require("beautiful")

local redutil  = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local signals = {}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function do_sloppy_focus(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end

local function fixed_maximized_geometry(c, context)
	if c.maximized and context ~= "fullscreen" then
		c:geometry({
			x = c.screen.workarea.x,
			y = c.screen.workarea.y,
			height = c.screen.workarea.height - 2 * c.border_width,
			width = c.screen.workarea.width - 2 * c.border_width
		})
	end
end

local gears = require('gears')
-- Build  table
-----------------------------------------------------------------------------------------------------------------------
function signals:init(args)

	args = args or {}
	local env = args.env
	

	function is_terminal(c)
    return (c.class and c.class:lower():match(env.terminal)) and true or false
	end
	function is_swallow(c)
		local swallow = require("color.pudding.swallow-config")
		return (c.class and swallow[c.class]) and true or false
		--return (c.name and swallow[c.name]) and true or false
		--return (c.name and c.name:match("Swallow")) and true or false
	end
	function copy_size(c, parent_client)
	    if not c or not parent_client then
	        return
	    end
	    if not c.valid or not parent_client.valid then
	        return
	    end
	    c.x=parent_client.x;
	    c.y=parent_client.y;
	    c.width=parent_client.width;
	    c.height=parent_client.height;
	end




	client.connect_signal("manage", function(c)
		if not awesome.startup then
			local parent_client=awful.client.focus.history.get(c.screen, 1)

			if parent_client and is_terminal(parent_client) and is_swallow(c) then
				

				awful.placement.no_offscreen(c)
				awful.client.setslave(c)
				local prev_focused = awful.client.focus.history.get(awful.screen.focused(), 1, nil)
				local prev_c = awful.client.next(-1, c)
				if prev_c and prev_focused then
					while prev_c ~= prev_focused do
						c:swap(prev_c)
						prev_c = awful.client.next(-1, c)
					end
				end

				parent_client.minimized = true
				parent_client.skip_taskbar = true
				parent_client.hidden = true
				c.ontop = parent_client.ontop
				c.below = parent_client.below
				c.maximized = parent_client.maximized
				c.floating = parent_client.floating
				c.sticky = parent_client.sticky
				copy_size(c, parent_client)
				c:connect_signal("unmanage", function(c)
					c.border_color = beautiful.border_color
					parent_client.minimized = false
					parent_client.skip_taskbar = false
					parent_client.hidden = false
					parent_client.ontop = c.ontop
					parent_client.below = c.below
					parent_client.maximized = c.maximized
					parent_client.floating = parent_client.floating --WHY DOES THIS NOT WORK WITCH C
					parent_client.sticky = c.sticky
					parent_client:move_to_tag(awful.tag.selected())
					copy_size(parent_client, c)
				end)


			else
				if env.set_slave then awful.client.setslave(c) end
			end

		--elseif awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		elseif awesome.startup and c.size_hints.user_position and c.size_hints.program_position then
					awful.placement.no_offscreen(c)
		end

		if not c.maximized then
			c.border_width = beautiful.border_width
			c.border_color = beautiful.border_color
			c.shape = function(cr,w,h)
				gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
			end
		else
			c.shape = function(cr,w,h)
				gears.shape.partially_rounded_rect(cr, w, h)
			end
		end

		--if env.set_center and c.floating and not (c.maximized or c.fullscreen) then
		-- if env.set_center and not (c.maximized or c.fullscreen) then
		-- 	redutil.placement.centered(c, nil, mouse.screen.workarea)
		-- end

		if (c.size_hints.user_position or c.size_hints.program_position) and not (c.maximized or c.fullscreen) then
					awful.placement.no_offscreen(c)
		elseif env.set_center and not (c.maximized or c.fullscreen) then
					redutil.placement.centered(c, nil, mouse.screen.workarea)
		end
		--awful.placement.no_offscreen(c)
		--awful.spawn.with_shell("notify-send test")
	end)


	-- -- actions on every application start
	-- client.connect_signal(
	-- 	"manage",
	-- 	function(c)
	--
	-- 		local parent_client=awful.client.focus.history.get(c.screen, 1)
	-- 		if parent_client and is_terminal(parent_client) and is_swallow(c) then
	-- 				--parent_client.child_resize=c
	--
	-- 				--awful.client.swap.byidx(-1)
	--
	-- 				parent_client.minimized = true
	-- 				parent_client.skip_taskbar = true
	-- 				parent_client.hidden = true
	-- 				c.maximized = parent_client.maximized
	-- 				c.floating = parent_client.floating
	-- 				c.sticky = parent_client.sticky
	-- 				copy_size(c, parent_client)
	--
	--
	--
		-- 				--awful.spawn.easy_async_with_shell("notify-send 1")
	-- 				-- awful.client.setslave(c)
	-- 				-- c:swap(parent_client)
	--
	--
	--
	--
	-- 				c:connect_signal("unmanage", function(c)
	-- 					parent_client.minimized = false
	-- 					parent_client.skip_taskbar = false
	-- 					parent_client.hidden = false
	-- 					parent_client.maximized = parent_client.maximized
	-- 					parent_client.floating = parent_client.floating
	-- 					parent_client.sticky = parent_client.sticky
	-- 					parent_client:move_to_tag(awful.tag.selected())
	-- 					copy_size(parent_client, c)
	-- 				end)
	--
	--
	--
	--
	-- 		end
	--
	--
	--
	-- 		if not c.maximized then
	-- 			c.border_width = beautiful.border_width
	-- 			c.shape = function(cr,w,h)
	-- 				gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
	-- 			end
	-- 		else
	-- 			c.shape = function(cr,w,h)
	-- 				gears.shape.partially_rounded_rect(cr, w, h)
	-- 			end
	-- 		end
	-- 		--c.shape = gears.shape.rounded_rect
	-- 		--c.shape = gears.shape.partially_rounded_rect(cr, 70, 70, true, true, false, true, 30)
	--
	-- 		-- put client at the end of list
	-- 		if env.set_slave then awful.client.setslave(c) end
	--
	-- 		-- startup placement
	-- 		if awesome.startup
	-- 		   and not c.size_hints.user_position
	-- 		   and not c.size_hints.program_position
	-- 		then
	-- 			awful.placement.no_offscreen(c)
	-- 		end
	--
	-- 		-- put new floating windows to the center of screen
	-- 		if env.set_center and c.floating and not (c.maximized or c.fullscreen) then
	-- 			redutil.placement.centered(c, nil, mouse.screen.workarea)
	-- 		end
	--
	-- 	end
	-- )


	client.connect_signal(
		"property::fullscreen",
		function(c)
			if not c.fullscreen then
				c.shape = function(cr,w,h)
					gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
				end
			else
				c.shape = function(cr,w,h)
					gears.shape.partially_rounded_rect(cr, w, h)
				end
			end
		end
	)
	-- add missing borders to windows that get unmaximized
	client.connect_signal(
		"property::maximized",
		function(c)
			if not c.maximized then
				c.border_width = beautiful.border_width
				c.border_color = beautiful.border_color
				c.shape = function(cr,w,h)
					gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
				end
			else
				c.border_color = beautiful.color.wibox
				c.shape = function(cr,w,h)
					gears.shape.partially_rounded_rect(cr, w, h)
				end
			end
		end
	)
	-- don't allow maximized windows move/resize themselves
	client.connect_signal(
		"request::geometry", fixed_maximized_geometry
	)

	-- enable sloppy focus, so that focus follows mouse
	if env.sloppy_focus then
		client.connect_signal("mouse::enter", do_sloppy_focus)
	end

	-- hilight border of focused window
	-- can be disabled since focus indicated by titlebars in current config
	if env.color_border_focus then
		client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
		client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
	end

	local oldscreen =awful.screen.focused().index
	awesome.connect_signal("refresh", function(s) 
		if awful.screen.focused().index ~= oldscreen then
			-- awful.screen.focus(awful.screen.focused().index)

			local c = awful.client.focus.history.get(awful.screen.focused(), 0)
			if c then client.focus = c end
			oldscreen = awful.screen.focused().index
			
		end
		screen.emit_signal("request::activate", {raise = true}) 
		
	end)



	screen.connect_signal("primary_changed", awesome.restart)
	screen.connect_signal("added", awesome.restart)
	screen.connect_signal("removed ", awesome.restart)

	-- /etc/udev/rules.d/99-charger-notification.rules
	-- SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/bin/awesome-client 'awesome.emit_signal("charging_status_change")'"
	-- SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/bin/awesome-client 'awesome.emit_signal("charging_status_change")'"
	-- sudo udevadm control --reload-rules
	-- 
	-- awesome.connect_signal("charging_status_change", awesome.restart)




	-- local function autorandr() 
	-- 	awful.spawn("autorandr --change" )
	-- 	awful.spawn("echo 'awesome.restart()' | awesome-client" )
	-- end
	-- screen.connect_signal("added", autorandr)
	-- screen.connect_signal("removed", autorandr)
	-- screen.connect_signal("list", autorandr)

	-- wallpaper update on screen geometry change
	screen.connect_signal("property::geometry", env.wallpaper)

	-- Awesome v4.0 introduce screen handling without restart.
	-- All redflat panel widgets was designed in old fashioned way and doesn't support this fature properly.
	-- Since I'm using single monitor setup I have no will to rework panel widgets by now,
	-- so restart signal added here is simple and dirty workaround.
	-- You can disable it on your own risk.
	screen.connect_signal("list", awesome.restart)
	-- screen.connect_signal("property::geometry", function () awful.spawn("setbg; setxkbmap 'us_intl,ru' 'altgr-intl,';") end) -- DIRTY LAYOUT FIX
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return signals
