-----------------------------------------------------------------------------------------------------------------------
--                                                  Menu config                                                      --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
local redflat = require("redflat")
local awful = require("awful")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local menu = {}


-- Build function
-----------------------------------------------------------------------------------------------------------------------
function menu:init(args)

	-- vars
	args = args or {}
	local env = args.env or {} -- fix this?
	local separator = args.separator or { widget = redflat.gauge.separator.horizontal() }
	local theme = args.theme or { auto_hotkey = true }
	local icon_style = args.icon_style or { custom_only = true, scalable_only = true }

	-- theme vars
	local default_icon = redflat.util.base.placeholder()
	local icon = redflat.util.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or default_icon
	local color = redflat.util.table.check(beautiful, "color.icon") and beautiful.color.icon or nil

	-- icon finder
	local function micon(name)
		return redflat.service.dfparser.lookup_icon(name, icon_style)
	end

	local function autorandr() 
		awful.spawn("autorandr -c && echo 'awesome.restart()' | awesome-client" )
	end

	local function sysact(action)
		local handle = io.popen("readlink -f /sbin/init" )
		local result = handle:read("*a")
		handle:close()
		if string.match (result, "systemd") then
			ctl="systemctl"
		else
			ctl="loginctl"
		end
		
		case = {
			["poweroff"] = function() awful.spawn({ctl, "poweroff"}) end,
			["reboot"] = function() awful.spawn({ctl, "reboot"}) end,
			["lock"] = function() awful.spawn("dbus-send --type=method_call --dest=org.gnome.ScreenSaver /org/gnome/ScreenSaver org.gnome.ScreenSaver.Lock") end,
			
		  }
		case[action]()
		
	end

	-- Application submenu
	------------------------------------------------------------
	local appmenu = redflat.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })
	-- Awesome submenu
	------------------------------------------------------------
	local awesomemenu = {
		{ "Autorandr",         autorandr,     micon("gnome-session-reboot") },
		separator,
		{ "Restart",         awesome.restart,                 micon("gnome-session-reboot") },
		{ "Close",         function() awesome.quit() awful.spawn.with_shell("killall xss-lock ; gnome-session-quit --logout --no-prompt") end,                micon("exit")                  },
		-- separator,
		-- { "Awesome config",  env.fm .. " .config/awesome",        micon("folder-bookmarks") },
		-- { "Awesome lib",     env.fm .. " /usr/share/awesome/lib", micon("folder-bookmarks") }
	}

	-- Places submenu
	------------------------------------------------------------
	local placesmenu = {
		{ "Documents",   env.fm .. " Documents", micon("folder-documents") },
		{ "Downloads",   env.fm .. " Downloads", micon("folder-download")  },
		{ "Music",       env.fm .. " Music",     micon("folder-music")     },
		{ "Pictures",    env.fm .. " Pictures",  micon("folder-pictures")  },
		{ "Videos",      env.fm .. " Videos",    micon("folder-videos")    },
		separator,
		{ "Media",       env.fm .. " /mnt/media",   micon("folder-bookmarks") },
		{ "Storage",     env.fm .. " /mnt/storage", micon("folder-bookmarks") },
	}

	-- Exit submenu
	------------------------------------------------------------
	local exitmenu = {
		{ "Reboot",          function() sysact("reboot") end,                    micon("gnome-session-reboot")  },
		{ "Shutdown",        function() sysact("poweroff") end,              micon("system-shutdown")       },
		separator,
		{ "Lock",     		 function() sysact("lock") end,  	micon("gnome-session-lock"), key = "l"   },
		{ "Switch user",     "dm-tool switch-to-greeter", micon("gnome-session-switch")  },
		{ "Suspend",         "systemctl suspend" ,        micon("gnome-session-suspend") },
	}

	-- Main menu
	------------------------------------------------------------
	self.mainmenu = redflat.menu({ theme = theme,
		items = {
			{ "Awesome",       awesomemenu, micon("awesome") },
			{ "Applications",  appmenu,     micon("distributor-logo") },
			{ "Places",        placesmenu,  micon("folder_home"), key = "c" },
			separator,
			{ "Terminal",      env.terminal, micon("terminal") },
			{ "File Manager",  env.fm,       micon("folder"), key = "n" },
			{ "Editor",        env.editor,      micon("emacs") },
			separator,
			{ "Exit",          exitmenu,     micon("exit") },
		}
	})

	-- Menu panel widget
	------------------------------------------------------------

	self.widget = redflat.gauge.svgbox(icon, nil, color)
	self.buttons = awful.util.table.join(
		awful.button({ }, 1, function () self.mainmenu:toggle() end)
	)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return menu