-----------------------------------------------------------------------------------------------------------------------
--                                              Autostart app list                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local autostart = {}

-- Application list function
--------------------------------------------------------------------------------
function autostart.run()
	local filesystem = require('gears.filesystem')
	local config_dir = filesystem.get_configuration_dir()
	-- environment
	-- awful.spawn.with_shell("notify-send $(gsettings get org.gnome.desktop.background picture-uri | sed "s|'||g" | sed "s|file://||")")
	-- awful.spawn.with_shell("gnome-flashback")
	awful.spawn.with_shell("pidof -s redshift || redshift -c " .. awful.util.get_configuration_dir() .. "newflat/widget/redshift/redshift.conf")
	awful.spawn.with_shell("pidof -s picom || picom")
	-- awful.spawn.with_shell("systemctl --user start gnome-flashback.service")
	-- awful.spawn.with_shell('picom -b --experimental-backends --config ' .. config_dir .. '/configuration/picom.conf')

--   awful.spawn.with_shell('xrdb -load /home/rjmvisser/.config/x11/xresources')
	-- -- gnome environment
	-- awful.spawn.with_shell("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	--
	--
	-- -- utils
	-- awful.spawn.with_shell("tint2")
	-- awful.spawn.with_shell("picom")
	-- awful.spawn.with_shell("mictray")
	-- awful.spawn.with_shell("nm-applet")
	-- awful.spawn.with_shell("volctl")
  -- awful.spawn.with_shell("gxkb")
	-- awful.spawn.with_shell("udiskie -As")
	-- awful.spawn.with_shell("albert")
	-- awful.spawn.with_shell("blueman-applet")
	-- awful.spawn.with_shell("evolution")
	-- awful.spawn.with_shell("fusuma -c /home/awesome/.config/fusuma/config.yml")
	--
	--
	--
	-- awful.spawn.with_shell("redshift -l 52.37:4.89")
	-- awful.spawn.with_shell("unclutter --noevents")
	-- awful.spawn.with_shell("unclutter -noevents")
	-- awful.spawn.with_shell("setxkbmap us_intl,ru altgr-intl, grp:caps_toggle")
end

-- Read and commands from file and spawn them
--------------------------------------------------------------------------------
function autostart.run_from_file(file_)
	local f = io.open(file_)
	for line in f:lines() do
		if line:sub(1, 1) ~= "#" then awful.spawn.with_shell(line) end
	end
	f:close()
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return autostart
