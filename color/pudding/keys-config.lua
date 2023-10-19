-----------------------------------------------------------------------------------------------------------------------
--                                          Hotkeys and mouse buttons config                                         --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local table = table
local awful = require("awful")
local redflat = require("redflat")
local newflat = require("newflat")
local beautiful = require("beautiful")

local naughty = require("naughty")

local sharedtags = require("sharedtags")
local gears = require('gears')
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = { mouse = {}, raw = {}, keys = {}, fake = {} }

-- key aliases
local settingsmenu = newflat.widget.settings.menu
local apprunner = redflat.float.apprunner
local appswitcher = redflat.float.appswitcher
local current = redflat.widget.tasklist.filter.currenttags
local allscr = redflat.widget.tasklist.filter.allscreen
local laybox = redflat.widget.layoutbox
local redtip = redflat.float.hotkeys
local laycom = redflat.layout.common
local grid = redflat.layout.grid
local map = redflat.layout.map
local redtitle = redflat.titlebar
local qlaunch = redflat.float.qlaunch

-- Key support functions
-----------------------------------------------------------------------------------------------------------------------

-- change window focus by history
local function focus_to_previous()
	awful.client.focus.history.previous()
	if client.focus then client.focus:raise() end
end
local function clockwise_to_previous()
	awful.client.focus.byidx(1)
	if client.focus then client.focus:raise() end
end
local function counterclockwise_to_previous()
	awful.client.focus.byidx(-1)
	if client.focus then client.focus:raise() end
end
-- change window focus by direction
local focus_switch_byd = function(dir)
	return function()
		awful.client.focus.bydirection(dir)
		if client.focus then client.focus:raise() end
	end
end
local focus_swap_byd = function(dir)
	return function()
		awful.client.swap.global_bydirection(dir)
		if client.focus then client.focus:raise() end
	end
end

-- minimize and restore windows
local function minimize_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) then c.minimized = true end
	end
end

local function minimize_all_except_focused()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c ~= client.focus then c.minimized = true end
	end
end

local function restore_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c.minimized then c.minimized = false end
	end
end

local function restore_client()
	local c = awful.client.restore()
	if c then client.focus = c; c:raise() end
end

-- close window
local function kill_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and not c.sticky then c:kill() end
	end
end

-- new clients placement
local function toggle_placement(env)
	env.set_slave = not env.set_slave
	redflat.float.notify:show({ text = (env.set_slave and "Slave" or "Master") .. " placement" })
end

-- numeric keys function builders
local function tag_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			local tag = tags[i]
			if tag then action(tag, awful.screen.focused()) end
			screen.emit_signal("request::activate", {raise = true})
		end
	)
end



local function client_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			if client.focus then
				local tag = tags[i]
				if tag then action(tag) end
				screen.emit_signal("request::activate", {raise = true})
			end
		end
	)
end

local function focustag(i, mod)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			local tag = tags[i]
			if tag then
				awful.screen.focus(tag.screen)
				tag:view_only()
				screen.emit_signal("request::activate", {raise = true})
			end
		end
	)
end
-- brightness functions
local brightness = function(args)
	newflat.widget.brightness.brightness:change_with_xbacklight(args) -- use xbacklight
	newflat.widget.brightness.slider:update()
end

-- right bottom corner position
local rb_corner = function()
	return { x = screen[mouse.screen].workarea.x + screen[mouse.screen].workarea.width,
	         y = screen[mouse.screen].workarea.y + screen[mouse.screen].workarea.height }
end

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init(args)

	-- Init vars
	args = args or {}
	local env = args.env
	local volume = args.volume
	local microphone = args.microphone
	local mainmenu = args.menu
	local appkeys = args.appkeys or {}

	-- self.mouse.root = (awful.util.table.join(
	-- 	awful.button({ }, 3, function () mainmenu:toggle() end),
	-- 	awful.button({ }, 4, awful.tag.viewnext),
	-- 	awful.button({ }, 5, awful.tag.viewprev)
	-- ))
	self.mouse.root = (awful.util.table.join(
		awful.button({ }, 3, function () mainmenu:toggle() end)
	))

	-- volume functions
	local volume_raise = function() volume:change_volume({ show_notify = true })              newflat.widget.audio.toggle:check() end
	local volume_lower = function() volume:change_volume({ show_notify = true, down = true }) newflat.widget.audio.toggle:check() end
	local volume_mute  = function() volume:mute({show_notify = true}) 						  newflat.widget.audio.toggle:check()end


	-- Init widgets
	redflat.float.qlaunch:init()

	-- Application hotkeys helper
	--------------------------------------------------------------------------------
	local apphelper = function(keys)
		if not client.focus then return end

		local app = client.focus.class:lower()
		for name, sheet in pairs(keys) do
			if name == app then
				redtip:set_pack(
						client.focus.class, sheet.pack, sheet.style.column, sheet.style.geometry,
						function() redtip:remove_pack() end
				)
				redtip:show()
				return
			end
		end

		redflat.float.notify:show({ text = "No tips for " .. client.focus.class })
	end

	-- Keys for widgets
	--------------------------------------------------------------------------------

	-- Apprunner widget
	------------------------------------------------------------
	local apprunner_keys_move = {
		{
			{ env.mod }, "k", function() apprunner:down() end,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "i", function() apprunner:up() end,
			{ description = "Select previous item", group = "Navigation" }
		},
	}

	-- apprunner:set_keys(awful.util.table.join(apprunner.keys.move, apprunner_keys_move), "move")
	apprunner:set_keys(apprunner_keys_move, "move")

	-- Menu widget
	------------------------------------------------------------
	local menu_keys_move = {
		{
			{ }, "k", redflat.menu.action.down,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ }, "Down", redflat.menu.action.down,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ }, "i", redflat.menu.action.up,
			{ description = "Select previous item", group = "Navigation" }
		},
		{
			{ }, "Up", redflat.menu.action.up,
			{ description = "Select previous item", group = "Navigation" }
		},
		{
			{ }, "j", redflat.menu.action.back,
			{ description = "Go back", group = "Navigation" }
		},
		{
			{ }, "Left", redflat.menu.action.back,
			{ description = "Go back", group = "Navigation" }
		},
		{
			{ }, "l", redflat.menu.action.enter,
			{ description = "Open submenu", group = "Navigation" }
		},
		{
			{ }, "Right", redflat.menu.action.enter,
			{ description = "Open submenu", group = "Navigation" }
		},
	}

	-- redflat.menu:set_keys(awful.util.table.join(redflat.menu.keys.move, menu_keys_move), "move")
	redflat.menu:set_keys(menu_keys_move, "move")

	-- Appswitcher widget
	------------------------------------------------------------
	local appswitcher_keys = {
		{
			{ env.mod }, "a", function() appswitcher:switch() end,
			{ description = "Select next app", group = "Navigation" }
		},
		{
			{ env.mod, "Shift" }, "a", function() appswitcher:switch() end,
			{} -- hidden key
		},
		{
			{ env.mod }, "q", function() appswitcher:switch({ reverse = true }) end,
			{ description = "Select previous app", group = "Navigation" }
		},
		{
			{ env.mod, "Shift" }, "q", function() appswitcher:switch({ reverse = true }) end,
			{} -- hidden key
		},
		{
			{}, "Super_L", function() appswitcher:hide() end,
			{ description = "Activate and exit", group = "Action" }
		},
		{
			{ env.mod }, "Super_L", function() appswitcher:hide() end,
			{} -- hidden key
		},
		{
			{ env.mod, "Shift" }, "Super_L", function() appswitcher:hide() end,
			{} -- hidden key
		},
		{
			{}, "Return", function() appswitcher:hide() end,
			{ description = "Activate and exit", group = "Action" }
		},
		{
			{}, "Escape", function() appswitcher:hide(true) end,
			{ description = "Exit", group = "Action" }
		},
		{
			{ env.mod }, "Escape", function() appswitcher:hide(true) end,
			{} -- hidden key
		},
		{
			{ env.mod }, "F1", function() redtip:show()  end,
			{ description = "Show hotkeys helper", group = "Action" }
		},
	}

	appswitcher:set_keys(appswitcher_keys)

	-- Settings menu widget
	------------------------------------------------------------
	
	local settingsmenu_keys = {
		{
			{  }, "Escape", function() settingsmenu:hide(true) end,
			{} -- hidden key
		},
		{
			{ "Control" }, "Left",function() microphone:change_volume({ show_notify = false, down = true }) newflat.widget.microphone.toggle:check()end,
			{ description = "Reduce microphone volume", group = "Microphone control" }
		},
		{
			{ "Control" }, "Right",function() microphone:change_volume({ show_notify = false }) newflat.widget.microphone.toggle:check()end,
			{ description = "Reduce microphone volume", group = "Microphone control" }
		},
		{
			{}, "m", function() microphone:mute({show_notify = false}) newflat.widget.microphone.toggle:check()end,
			{ description = "Toggle microphone mute", group = "Microphone control" }
		},
		{
			{}, "a", function() volume:mute({show_notify = false}) newflat.widget.audio.toggle:check()end,
			{ description = "Toggle audio mute", group = "Volume control" }
		},
		{
			{}, "Left", function() volume:change_volume({ show_notify = false, down = true }) newflat.widget.audio.toggle:check()end,
			{ description = "Reduce audio volume", group = "Volume control" }
		},
		{
			{}, "Right", function() volume:change_volume({ show_notify = false }) newflat.widget.audio.toggle:check()end,
			{ description = "Increase audio volume", group = "Volume control" }
		},
		{
			{ "Shift" }, "Left",function() brightness({show_notify = false, step = 5, down = true }) end,
			{ description = "Reduce brightness", group = "Volume control" }
		},
		{
			{ "Shift" }, "Right",function() brightness({show_notify = false, step = 5 }) end,
			{ description = "Reduce brightness", group = "Volume control" }
		},
		{
			{}, "r", function() newflat.widget.refresher.refresh:toggle() end,
			{ description = "Toggle refresher", group = "Widgets" }
		},
		{
			{}, "p", function() newflat.widget.notifications.toggle:toggle() end,
			{ description = "Toggle do not disturb", group = "Widgets" }
		},
		{
			{ env.mod }, "F1", function() redtip:show()  end,
			{ description = "Show hotkeys helper", group = "Action" }
		},
	}

	settingsmenu:set_keys(settingsmenu_keys)




	-- Emacs like key sequences
	--------------------------------------------------------------------------------

	-- initial key
	local keyseq = { { env.mod }, "c", {}, {} }

	-- group
	keyseq[3] = {
		{ {}, "k", {}, {} }, -- application kill group
		{ {}, "c", {}, {} }, -- client managment group
		{ {}, "r", {}, {} }, -- client managment group
		{ {}, "n", {}, {} }, -- client managment group
		{ {}, "g", {}, {} }, -- run or rise group
		{ {}, "f", {}, {} }, -- launch application group
	}

	-- quick launch key sequence actions
	for i = 1, 9 do
		local ik = tostring(i)
		table.insert(keyseq[3][5][3], {
			{}, ik, function() qlaunch:run_or_raise(ik) end,
			{ description = "Run or rise application №" .. ik, group = "Run or Rise", keyset = { ik } }
		})
		table.insert(keyseq[3][6][3], {
			{}, ik, function() qlaunch:run_or_raise(ik, true) end,
			{ description = "Launch application №".. ik, group = "Quick Launch", keyset = { ik } }
		})
	end

	-- application kill sequence actions
	keyseq[3][1][3] = {
		{
			{}, "f", function() if client.focus then client.focus:kill() end end,
			{ description = "Kill focused client", group = "Kill application", keyset = { "f" } }
		},
		{
			{}, "a", kill_all,
			{ description = "Kill all clients with current tag", group = "Kill application", keyset = { "a" } }
		},
	}

	-- client managment sequence actions
	keyseq[3][2][3] = {
		{
			{}, "p", function () toggle_placement(env) end,
			{ description = "Switch master/slave window placement", group = "Clients managment", keyset = { "p" } }
		},
	}

	keyseq[3][3][3] = {
		{
			{}, "f", restore_client,
			{ description = "Restore minimized client", group = "Clients managment", keyset = { "f" } }
		},
		{
			{}, "a", restore_all,
			{ description = "Restore all clients with current tag", group = "Clients managment", keyset = { "a" } }
		},
	}

	keyseq[3][4][3] = {
		{
			{}, "f", function() if client.focus then client.focus.minimized = true end end,
			{ description = "Minimized focused client", group = "Clients managment", keyset = { "f" } }
		},
		{
			{}, "a", minimize_all,
			{ description = "Minimized all clients with current tag", group = "Clients managment", keyset = { "a" } }
		},
		{
			{}, "e", minimize_all_except_focused,
			{ description = "Minimized all clients except focused", group = "Clients managment", keyset = { "e" } }
		},
	}


	-- Layouts
	--------------------------------------------------------------------------------

	-- shared layout keys
	local layout_tile = {
		{
			{ env.mod }, "l", function () awful.tag.incmwfact( 0.05) end,
			{ description = "Increase master width factor", group = "Layout" }
		},
		{
			{ env.mod }, "j", function () awful.tag.incmwfact(-0.05) end,
			{ description = "Decrease master width factor", group = "Layout" }
		},
		{
			{ env.mod }, "i", function () awful.client.incwfact( 0.05) end,
			{ description = "Increase window factor of a client", group = "Layout" }
		},
		{
			{ env.mod }, "k", function () awful.client.incwfact(-0.05) end,
			{ description = "Decrease window factor of a client", group = "Layout" }
		},
		{
			{ env.mod, }, "+", function () awful.tag.incnmaster( 1, nil, true) end,
			{ description = "Increase the number of master clients", group = "Layout" }
		},
		{
			{ env.mod }, "-", function () awful.tag.incnmaster(-1, nil, true) end,
			{ description = "Decrease the number of master clients", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "+", function () awful.tag.incncol( 1, nil, true) end,
			{ description = "Increase the number of columns", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "-", function () awful.tag.incncol(-1, nil, true) end,
			{ description = "Decrease the number of columns", group = "Layout" }
		},
	}

	laycom:set_keys(layout_tile, "tile")

	-- grid layout keys
	local layout_grid_move = {
		{
			{ env.mod }, "KP_Up", function() grid.move_to("up") end,
			{ description = "Move window up", group = "Movement" }
		},
		{
			{ env.mod }, "KP_Down", function() grid.move_to("down") end,
			{ description = "Move window down", group = "Movement" }
		},
		{
			{ env.mod }, "KP_Left", function() grid.move_to("left") end,
			{ description = "Move window left", group = "Movement" }
		},
		{
			{ env.mod }, "KP_right", function() grid.move_to("right") end,
			{ description = "Move window right", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Up", function() grid.move_to("up", true) end,
			{ description = "Move window up by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Down", function() grid.move_to("down", true) end,
			{ description = "Move window down by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Left", function() grid.move_to("left", true) end,
			{ description = "Move window left by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Right", function() grid.move_to("right", true) end,
			{ description = "Move window right by bound", group = "Movement" }
		},
	}

	local layout_grid_resize = {
		{
			{ env.mod }, "i", function() grid.resize_to("up") end,
			{ description = "Inrease window size to the up", group = "Resize" }
		},
		{
			{ env.mod }, "k", function() grid.resize_to("down") end,
			{ description = "Inrease window size to the down", group = "Resize" }
		},
		{
			{ env.mod }, "j", function() grid.resize_to("left") end,
			{ description = "Inrease window size to the left", group = "Resize" }
		},
		{
			{ env.mod }, "l", function() grid.resize_to("right") end,
			{ description = "Inrease window size to the right", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "i", function() grid.resize_to("up", nil, true) end,
			{ description = "Decrease window size from the up", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "k", function() grid.resize_to("down", nil, true) end,
			{ description = "Decrease window size from the down", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "j", function() grid.resize_to("left", nil, true) end,
			{ description = "Decrease window size from the left", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "l", function() grid.resize_to("right", nil, true) end,
			{ description = "Decrease window size from the right", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "i", function() grid.resize_to("up", true) end,
			{ description = "Increase window size to the up by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "k", function() grid.resize_to("down", true) end,
			{ description = "Increase window size to the down by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "j", function() grid.resize_to("left", true) end,
			{ description = "Increase window size to the left by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "l", function() grid.resize_to("right", true) end,
			{ description = "Increase window size to the right by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "i", function() grid.resize_to("up", true, true) end,
			{ description = "Decrease window size from the up by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "k", function() grid.resize_to("down", true, true) end,
			{ description = "Decrease window size from the down by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "j", function() grid.resize_to("left", true, true) end,
			{ description = "Decrease window size from the left by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "l", function() grid.resize_to("right", true, true) end,
			{ description = "Decrease window size from the right by bound ", group = "Resize" }
		},
	}

	redflat.layout.grid:set_keys(layout_grid_move, "move")
	redflat.layout.grid:set_keys(layout_grid_resize, "resize")

	-- user map layout keys
	local layout_map_layout = {
		{
			{ env.mod }, "s", function() map.swap_group() end,
			{ description = "Change placement direction for group", group = "Layout" }
		},
		{
			{ env.mod }, "v", function() map.new_group(true) end,
			{ description = "Create new vertical group", group = "Layout" }
		},
		{
			{ env.mod }, "h", function() map.new_group(false) end,
			{ description = "Create new horizontal group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "v", function() map.insert_group(true) end,
			{ description = "Insert new vertical group before active", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "h", function() map.insert_group(false) end,
			{ description = "Insert new horizontal group before active", group = "Layout" }
		},
		{
			{ env.mod }, "d", function() map.delete_group() end,
			{ description = "Destroy group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "d", function() map.clean_groups() end,
			{ description = "Destroy all empty groups", group = "Layout" }
		},
		{
			{ env.mod }, "f", function() map.set_active() end,
			{ description = "Set active group", group = "Layout" }
		},
		{
			{ env.mod }, "g", function() map.move_to_active() end,
			{ description = "Move focused client to active group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "f", function() map.hilight_active() end,
			{ description = "Hilight active group", group = "Layout" }
		},
		{
			{ env.mod }, "a", function() map.switch_active(1) end,
			{ description = "Activate next group", group = "Layout" }
		},
		{
			{ env.mod }, "q", function() map.switch_active(-1) end,
			{ description = "Activate previous group", group = "Layout" }
		},
		{
			{ env.mod }, "]", function() map.move_group(1) end,
			{ description = "Move active group to the top", group = "Layout" }
		},
		{
			{ env.mod }, "[", function() map.move_group(-1) end,
			{ description = "Move active group to the bottom", group = "Layout" }
		},
		{
			{ env.mod }, "r", function() map.reset_tree() end,
			{ description = "Reset layout structure", group = "Layout" }
		},
	}

	local layout_map_resize = {
		{
			{ env.mod }, "j", function() map.incfactor(nil, 0.1, false) end,
			{ description = "Increase window horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod }, "l", function() map.incfactor(nil, -0.1, false) end,
			{ description = "Decrease window horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod }, "i", function() map.incfactor(nil, 0.1, true) end,
			{ description = "Increase window vertical size factor", group = "Resize" }
		},
		{
			{ env.mod }, "k", function() map.incfactor(nil, -0.1, true) end,
			{ description = "Decrease window vertical size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "j", function() map.incfactor(nil, 0.1, false, true) end,
			{ description = "Increase group horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "l", function() map.incfactor(nil, -0.1, false, true) end,
			{ description = "Decrease group horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "i", function() map.incfactor(nil, 0.1, true, true) end,
			{ description = "Increase group vertical size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "k", function() map.incfactor(nil, -0.1, true, true) end,
			{ description = "Decrease group vertical size factor", group = "Resize" }
		},
	}

	redflat.layout.map:set_keys(layout_map_layout, "layout")
	redflat.layout.map:set_keys(layout_map_resize, "resize")


	-- Global keys
	--------------------------------------------------------------------------------
	self.raw.root = {
		{
			{ env.mod }, "space", function(c) naughty.destroy_all_notifications() end,
			{ description = "Destroy all notification pop-ups", group = "Main" }
		},
		{
			 { env.mod }, "b",
			 function()
				 local s = awful.screen.focused()
				 s.panel.visible = not s.panel.visible
				 -- awful.spawn(os.getenv("HOME") .. "/.config/picom/toggle.sh")
				 if beautiful.wibar_detached then
					 s.useless_wibar.visible = not s.useless_wibar.visible
				 end
			 end,
			 {description = "Toggle topbar", group = "Main"},
		 },
		 {
			 { env.mod, "Shift" }, "space", function() redflat.widget.keyboard:toggle() end,
			 { description = "Toggle keyboard layout", group = "Main" }
		 },
		{
			{ env.mod }, "F1", function() redtip:show() end,
			{ description = "[Hold] Show awesome hotkeys helper", group = "Main" }
		},
		{
			{ env.mod, "Control" }, "F1", function() apphelper(appkeys) end,
			{ description = "[Hold] Show hotkeys helper for application", group = "Main" }
		},
		{
			{ env.mod }, "c", function() redflat.float.keychain:activate(keyseq, "User") end,
			{ description = "[Hold] User key sequence", group = "Main" }
		},

		{
			{ env.mod }, "F2", function () redflat.service.navigator:run() end,
			{ description = "[Hold] Tiling window control mode", group = "Window control" }
		},
		{
			{ env.mod }, "h", function() redflat.float.control:show() end,
			{ description = "[Hold] Floating window control mode", group = "Window control" }
		},

		{
			{ env.mod }, "Return", function() awful.spawn(env.terminal) end,
			{ description = "Terminal", group = "Programs" }
		},
		-- {
		-- 	{ env.mod, "Shift"  }, "Return", function () awful.spawn(env.terminal, { floating=true } ) end,
		-- 					{ description = "Floating Terminal", group = "Programs"},
		-- },
		{
			{ env.mod, "Shift"  }, "Return", function () awful.spawn(env.terminal .. " terminal-floating" ) end,
							{ description = "Floating Terminal", group = "Programs"},
		},
		-- {
		-- 	{ env.mod, "Mod1" }, "space", function() awful.spawn("gpaste-client ui") end,
		-- 	{ description = "Clipboard manager", group = "Actions" }
		-- },
		-- {
		-- 	{ env.mod }, "dead_grave", function () awful.screen.focus_relative(1) screen.emit_signal("request::activate", {raise = true}) end,
		-- 					{ description = "Focus the next display", group = "Display"},
		-- },
		-- {
		-- 	{ env.mod, "Shift" }, "dead_grave", function () awful.screen.focus_relative(-1) screen.emit_signal("request::activate", {raise = true}) end,
		-- 					{ description = "Focus the previous display", group = "Display"},
		-- },
		{
			{ env.mod }, "comma", function () awful.screen.focus_relative(1) screen.emit_signal("request::activate", {raise = true}) end,
							{ description = "Focus the next display", group = "Display"},
		},
		{
			{ env.mod}, "period" , function () awful.screen.focus_relative(-1) screen.emit_signal("request::activate", {raise = true}) end,
							{ description = "Focus the previous display", group = "Display"},
		},
		{
			{ env.mod }, "\\", function () awful.spawn("drawterminal", { floating=true } ) end,
							{ description = "Draw a terminal", group = "Programs"},
		},
		{
			{ env.mod, "Control" }, "r", awesome.restart,
			{ description = "Reload WM", group = "Main" }
		},
		{
			{ env.mod, "Shift" }, "r", function () awful.spawn("autorandr --change" ) end; awesome.restart ,
			{ description = "Autorandr", group = "Main" }
		},
		{
			{ env.mod }, "l", focus_switch_byd("right"),
			{ description = "Go to right client", group = "Client navigation" }
		},
		{
			{ env.mod, "Shift" }, "l", focus_swap_byd("right"),
			{ description = "Swap with right client", group = "Client navigation" }
		},
		{
			{ env.mod }, "j", focus_switch_byd("left"),
			{ description = "Go to left client", group = "Client navigation" }
		},
		{
			{ env.mod, "Shift" }, "j", focus_swap_byd("left"),
			{ description = "Swap with left client", group = "Client navigation" }
		},
		{
			{ env.mod }, "i", focus_switch_byd("up"),
			{ description = "Go to upper client", group = "Client navigation" }
		},
		{
			{ env.mod, "Shift" }, "i", focus_swap_byd("up"),
			{ description = "Swap with up client", group = "Client navigation" }
		},
		{
			{ env.mod }, "k", focus_switch_byd("down"),
			{ description = "Go to lower client", group = "Client navigation" }
		},
		{
			{ env.mod, "Shift" }, "k", focus_swap_byd("down"),
			{ description = "Swap with down client", group = "Client navigation" }
		},
		{
			{ env.mod }, "u", awful.client.urgent.jumpto,
			{ description = "Go to urgent client", group = "Client navigation" }
		},
		-- {
		-- 	{ env.mod }, "Tab", focus_to_previous,
		-- 	{ description = "Go to previos client", group = "Client focus" }
		-- },
		{
			{ env.mod }, "Tab", clockwise_to_previous,
			{ description = "Go to previous client", group = "Client navigation" }
		},
		{
			{ env.mod, "Shift" }, "Tab", counterclockwise_to_previous,
			{ description = "Go to previous client", group = "Client navigation" }
		},
		{
			{ env.mod }, "w", function() mainmenu:show() end,
			{ description = "Main menu", group = "Widgets" }
		},
		{
			-- { env.mod }, "r", function() apprunner:show() end,
			-- { description = "Application launcher", group = "Widgets" }
			-- { env.mod }, "r", function() awful.spawn(os.getenv("HOME") .. "/.config/rofi/launchers/colorful/launcher.sh") end,
			-- { description = "Application launcher", group = "Widgets" }
			--{ env.mod }, "r", function() awful.spawn("j4-dmenu-desktop --dmenu='dmenu -l 3 -g 4 -i'") end,
			-- { env.mod }, "e", function() awful.spawn("j4-dmenu-desktop --usage-log=.cache/desktop-dmenu " .. awful.screen.focused().index - 1) end,
			{ env.mod }, "e", function() awful.spawn("/home/rick/.config/rofi/launchers/type-1/launcher.sh " .. awful.screen.focused().index - 1) end,
			{ description = "Application launcher", group = "Programs" }
		},
		{
			{ env.mod }, "r", function() awful.spawn("dmenupassmenu") end,
			{ description = "Password Manager", group = "Programs" }
		},
		{
			{ env.mod, "Control" }, "l", function() awful.spawn("dmenuhandler") end,
			{ description = "Link handler", group = "Programs" }
		},
		{
			{ env.mod }, "End", function() awful.spawn("sysact") end,
			{ description = "System Activity", group = "Programs" }
		},
		-- {
		-- 	{ env.mod }, "p", function() redflat.float.prompt:run() end,
		-- 	{ description = "Show the prompt box", group = "Widgets" }
		-- },
		-- {
		-- 	{ env.mod }, "x", function() redflat.float.top:show("cpu") end,
		-- 	{ description = "Show the top process list", group = "Widgets" }
		-- },
		-- {
		-- 	{ env.mod, "Control" }, "m", function() redflat.widget.mail:update(true) end,
		-- 	{ description = "Check new mail", group = "Widgets" }
		-- },
		{
			{ env.mod, "Control" }, "i", function() newflat.widget.tray.systoggler:toggle() end,
			{ description = "Toggle tray", group = "Widgets" }
		},
		-- {
		-- 	{ env.mod, "Control" }, "u", function() redflat.widget.updates:update(true) end,
		-- 	{ description = "Check available updates", group = "Widgets" }
		-- },
		-- {
		-- 	{ env.mod }, "g", function() qlaunch:show() end,
		-- 	{ description = "Application quick launcher", group = "Widgets" }
		-- },
		-- {
		-- 	{ env.mod }, "z", function() redflat.service.logout:show() end,
		-- 	{ description = "Log out screen", group = "Widgets" }
		-- },
		-- {
		-- 	{ env.mod }, "z", function() awful.spawn(os.getenv("HOME") .. "/.local/bin/powermenu") end,
		-- 	{ description = "Log out screen", group = "Widgets" }
		-- },
		{
			{ env.mod }, "y", function() laybox:toggle_menu(mouse.screen.selected_tag) end,
			{ description = "Show layout menu", group = "Layouts" }
		},
		{
			{ env.mod}, "Up", function() awful.layout.inc(1) end,
			{ description = "Select next layout", group = "Layouts" }
		},
		{
			{ env.mod }, "Down", function() awful.layout.inc(-1) end,
			{ description = "Select previous layout", group = "Layouts" }
		},
		{
			{}, "Print", function() awful.spawn("gnome-screenshot -i") end,
			{ description = "Screenshot Manager", group = "Programs" }
		},
		-- {
		-- 	{}, "XF86MonBrightnessUp", function() brightness({ step = 5 }) end,
		-- 	{ description = "Increase brightness", group = "Brightness control" }
		-- },
		-- {
		-- 	{}, "XF86MonBrightnessDown", function() brightness({ step = 5, down = true }) end,
		-- 	{ description = "Reduce brightness", group = "Brightness control" }
		-- },
		-- {
		-- 	{}, "XF86AudioRaiseVolume", volume_raise,
		-- 	{ description = "Increase volume", group = "Volume control" }
		-- },
		-- {
		-- 	{}, "XF86AudioLowerVolume", volume_lower,
		-- 	{ description = "Reduce volume", group = "Volume control" }
		-- },
		-- {
		-- 	{}, "XF86AudioMute", volume_mute,
		-- 	{ description = "Mute audio", group = "Volume control" }
		-- },
		{
			{ env.mod }, "p", nil, function() newflat.widget.notifications.menu:toggle_menu() end,
			{ description = "Notification menu", group = "Widgets"}
		},
		{
			{ env.mod }, "s", nil, function() newflat.widget.settings.menu:toggle_menu() end,
			{ description = "Settings menu", group = "Widgets"}
		},

		{
			{ env.mod }, "a", nil, function() appswitcher:show({ filter = current }) end,
			{ description = "Switch to next with current tag", group = "Application switcher" }
		},
		{
			{ env.mod }, "q", nil, function() appswitcher:show({ filter = current, reverse = true }) end,
			{ description = "Switch to previous with current tag", group = "Application switcher" }
		},
		{
			{ env.mod, "Shift" }, "a", nil, function() appswitcher:show({ filter = allscr }) end,
			{ description = "Switch to next through all tags", group = "Application switcher" }
		},
		{
			{ env.mod, "Shift" }, "q", nil, function() appswitcher:show({ filter = allscr, reverse = true }) end,
			{ description = "Switch to previous through all tags", group = "Application switcher" }
		},

		{
			{ env.mod }, "Escape", awful.tag.history.restore,
			{ description = "Focus previous focused tag", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Right", awful.tag.viewnext,
			{ description = "View higher tag", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Left", awful.tag.viewprev,
			{ description = "View lower tag", group = "Tag navigation" }
		},

		{
			{ env.mod, "Control", "Shift" }, "t", function() redtitle.toggle(client.focus) end,
			{ description = "Toggle titlebar for focused client", group = "Titlebar" }
		},
		--{
		--	{ env.mod, "Control" }, "t", function() redtitle.switch(client.focus) end,
		--	{ description = "Switch titlebar view for focused client", group = "Titlebar" }
		--},
		{
			{ env.mod, "Shift" }, "t", function() redtitle.toggle_all() end,
			{ description = "Toggle titlebar for all clients", group = "Titlebar" }
		},
		{
			{ env.mod}, "t", function() redtitle.global_switch() end,
			{ description = "Switch titlebar view for all clients", group = "Titlebar" }
		},
		{
			{ env.mod}, "=", function() awful.tag.incgap(1) end,
			{ description = "Increase gap size", group = "Display" }
		},
		{
			{ env.mod}, "-", function() awful.tag.incgap(-1) end,
			{ description = "Decrease gap size", group = "Display" }
		},
		{
			{ env.mod, "Shift"}, "=", function() awful.tag.setgap(beautiful.useless_gap) end,
			{ description = "Reset gap size", group = "Display" }
		},
		{
			{ env.mod, "Shift"}, "-", function() awful.tag.setgap(0) end,
			{ description = "Disable gap", group = "Display" }
		},

		{
			{ env.mod, "Shift" }, "Right", function()
			local screen = awful.screen.focused()
			local t = screen.selected_tag
			if t then
				local idx = t.index + 1
				if idx > #screen.tags then idx = 1 end
				if client.focus then
					-- local tags = root.tags()
					client.focus:move_to_tag(screen.tags[idx])
					-- screen.tags[idx]:view_only()
				end
			end
		end,
		{description = "move focused client to next tag and view tag", group = "tag"}
		},
  
		{
			{ env.mod, "Shift" },  "Left", function()
			local screen = awful.screen.focused()
			local t = screen.selected_tag
			if t then
				local idx = t.index - 1
				if idx == 0 then idx = #screen.tags end
				if client.focus then
					-- local tags = root.tags()
					client.focus:move_to_tag(screen.tags[idx])
					-- screen.tags[idx]:view_only()
				end
			end
		end,
		{description = "move focused client to previous tag and view tag", group = "tag"}
		},
		{
			{ env.mod, "Shift" }, "comma", function () 
				local c = client.focus
				if c then c:move_to_screen(awful.screen.focused().index+1) awful.screen.focus_relative(-1) screen.emit_signal("request::activate", {raise = true}) end
			end,
			{ description = "Focus the next display", group = "Display"},
		},
		{
			{ env.mod, "Shift"}, "period" , function () 
				local c = client.focus
				if c then c:move_to_screen(awful.screen.focused().index-1) awful.screen.focus_relative(1) screen.emit_signal("request::activate", {raise = true}) end
			end,
							{ description = "Focus the previous display", group = "Display"},
		},
		




		-- {
		-- 	{ env.mod }, "e", function() newflat.widget.player.player:show(rb_corner()) end,
		-- 	{ description = "Show/hide widget", group = "Audio player" }
		-- },
		-- {
		-- 	{}, "XF86AudioPlay", function() redflat.float.player:action("PlayPause") end,
		-- 	{ description = "Play/Pause track", group = "Audio player" }
		-- },
		-- {
		-- 	{}, "XF86AudioNext", function() redflat.float.player:action("Next") end,
		-- 	{ description = "Next track", group = "Audio player" }
		-- },
		-- {
		-- 	{}, "XF86AudioPrev", function() redflat.float.player:action("Previous") end,
		-- 	{ description = "Previous track", group = "Audio player" }
		-- },
		-- {
		-- 	{ env.mod, "Control" }, "s", function() for s in screen do env.wallpaper(s) end end,
		-- 	{} -- hidden key
		-- }
		-- {
		-- 	{ }, "", function() screen.emit_signal("test::test") end, function() screen.emit_signal("test::test2") end,
		-- 	{ description = "Destroy all notification pop-ups", group = "Main" }
		-- },
	}

	-- Client keys
	--------------------------------------------------------------------------------
	self.raw.client = {
		{
			{ env.mod }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
			{ description = "Toggle fullscreen", group = "Client keys" }
		},
		{
			{ env.mod }, "F4", function(c) c:kill() end,
			{ description = "Close", group = "Client keys" }
		},
		{
			{ env.mod }, "x", function(c) c:kill() end,
			{ description = "Close", group = "Client keys" }
		},
		{
			{ env.mod, "Control" }, "f", awful.client.floating.toggle,
			{ description = "Toggle floating", group = "Client keys" }
		},
		{
			{ env.mod, "Control" }, "o", function(c) c.ontop = not c.ontop end,
			{ description = "Toggle keep on top", group = "Client keys" }
		},
		{
			{ env.mod }, "n", function(c) c.minimized = true end,
			{ description = "Minimize", group = "Client keys" }
		},
		{
			{ env.mod }, "m", function(c) c.maximized = not c.maximized; c:raise() end,
			{ description = "Maximize", group = "Client keys" }
		}
	}

	self.keys.root = redflat.util.key.build(self.raw.root)
	self.keys.client = redflat.util.key.build(self.raw.client)

	-- Numkeys
	--------------------------------------------------------------------------------

	-- add real keys without description here
	for i = 1, 9 do
		self.keys.root = awful.util.table.join(
			self.keys.root,
			--focustag(i,    { env.mod, "Control"  }),
			-- tag_numkey(i,    { env.mod },                     function(t) sharedtags.viewonly(t) end),
			tag_numkey(i,    { env.mod, "Control", "Shift" },          function(t) sharedtags.viewtoggle(t) end),
			client_numkey(i, { env.mod, "Shift" },            function(t) client.focus:move_to_tag(t) end),
			--client_numkey(i, { env.mod, "Control", "Shift" }, function(t) client.focus:toggle_tag(t)  end)
			tag_numkey(i,    { env.mod, "Control" },                     function(t) sharedtags.viewonly(t) end),
			focustag(i,    { env.mod })
		)
	end

	
	

	-- tag_numkey(i,    { env.mod },                     function(t) t:view_only()               end),
	-- tag_numkey(i,    { env.mod, "Control" },          function(t) awful.tag.viewtoggle(t)     end),

	local numkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

	self.fake.numkeys = {
		{
			{ env.mod }, "1..9", nil,
			{ description = "Switch to tag", group = "Tag navigation", keyset = numkeys }
		},
		{
			{ env.mod, "Control" }, "1..9", nil,
			{ description = "Move tag to focused display", group = "Display", keyset = numkeys }
		},
		{
			{ env.mod, "Shift" }, "1..9", nil,
			{ description = "Move focused client to tag", group = "Client navigation", keyset = numkeys }
		},
		{
			{ env.mod, "Control", "Shift" }, "1..9", nil,
			{ description = "Combine tag with focused tag", group = "Tag navigation", keyset = numkeys }
		},
	}

	-- Hotkeys helper setup
	--------------------------------------------------------------------------------
	redflat.float.hotkeys:set_pack("Main", awful.util.table.join(self.raw.root, self.raw.client, self.fake.numkeys), 2)

	-- Mouse buttons
	--------------------------------------------------------------------------------
	self.mouse.client = awful.util.table.join(
		awful.button({}, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ env.mod }, 1, awful.mouse.client.move),
		awful.button({}, 2, awful.mouse.client.move),
		awful.button({ env.mod }, 3, awful.mouse.client.resize),
		awful.button({}, 8, function(c) c:kill() end)
	)

	-- Set root hotkeys
	--------------------------------------------------------------------------------
	root.keys(self.keys.root)
	root.buttons(self.mouse.root)

end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
