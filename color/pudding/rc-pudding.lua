-----------------------------------------------------------------------------------------------------------------------
--                                                   Green config                                                    --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")
local newflat = require("newflat")
-- debug locker
local lock = lock or {}

redflat.startup.locked = lock.autostart
redflat.startup:activate()

-- Error handling
-----------------------------------------------------------------------------------------------------------------------
-- require("colorless.ercheck-config") -- load file with error handling



-- Disable naughty notifications
-----------------------------------------------------------------------------------------------------------------------
-- local _dbus = dbus; dbus = nil
-- local naughty = require("naughty")
-- dbus = _dbus


-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("color.pudding.env-config") -- load file with environment
env:init({ theme = "pudding" })


-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("color.pudding.layout-config") -- load file with tile layouts setup
layouts:init()


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("color.pudding.menu-config") -- load file with menu configuration
mymenu:init({ env = env })

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}
tasklist.style = { appnames = require("color.pudding.alias-config")}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, newflat.widget.tasklist.tasklist.action.select),
	awful.button({}, 2, newflat.widget.tasklist.tasklist.action.close),
	awful.button({}, 3, newflat.widget.tasklist.tasklist.action.menu),
	awful.button({}, 4, newflat.widget.tasklist.tasklist.action.switch_next),
	awful.button({}, 5, newflat.widget.tasklist.tasklist.action.switch_prev)
)

-- Notifications
--------------------------------------------------------------------------------
local notifications = {}
newflat.widget.notifications.menu:init()
notifications.widget = newflat.widget.notifications.menu()

notifications.buttons = awful.util.table.join(
	awful.button({}, 1, function () newflat.widget.notifications.menu:toggle_menu() end)
)


-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { widget = redflat.gauge.tag.green.new, show_tip = true }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() screen.emit_signal("request::activate", {raise = true}) end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle ),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) screen.emit_signal("request::activate", {raise = true}) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) screen.emit_signal("request::activate", {raise = true}) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%I:%M %p", dateformat = "%R %a %d %b[%m] %Y" })

-- Software update indcator
--------------------------------------------------------------------------------
-- redflat.widget.updates:init({ command = env.updates })

-- Layoutbox configure
--------------------------------------------------------------------------------
-- just init layout menu without panel widget
redflat.widget.layoutbox:init(awful.layout.layouts)

-- Tray widget
--------------------------------------------------------------------------------
-- local tray = {}
-- tray.widget = redflat.widget.minitray()
--
-- tray.buttons = awful.util.table.join(
-- 	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
-- )


-- PA microphone
--------------------------------------------------------------------------------
local microphone = {}

-- tricky custom style
-- local microphone_style = {
-- 	widget = redflat.gauge.audio.red.new,
-- 	audio = beautiful.individual and beautiful.individual.microphone_audio or {},
-- }
-- -- microphone_style.audio.gauge = redflat.gauge.monitor.dash
-- microphone_style.audio.gauge = false

-- init widget
microphone.widget = newflat.widget.microphone.pulse({}, microphone_style)

-- microphone.buttons = awful.util.table.join(
-- 	awful.button({}, 2, function() microphone.widget:mute() end),
-- 	awful.button({}, 4, function() microphone.widget:change_volume() end),
-- 	awful.button({}, 5, function() microphone.widget:change_volume({ down = true }) end)
-- )

local microphone_slider = {}
newflat.widget.microphone.slider:init({})
microphone_slider.widget = newflat.widget.microphone.slider()

local microphone_toggle = {}
newflat.widget.microphone.toggle:init({ microphone=microphone.widget })
microphone_toggle.widget = newflat.widget.microphone.toggle()
microphone_toggle.buttons = awful.util.table.join(
	awful.button({}, 1, function () newflat.widget.microphone.toggle:toggle({microphone=microphone.widget}) end),
	awful.button({}, 4, function () newflat.widget.microphone.toggle:toggle({microphone=microphone.widget}) end),
	awful.button({}, 5, function () newflat.widget.microphone.toggle:toggle({microphone=microphone.widget}) end)
)
-- PA volume control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = newflat.widget.audio.pulse()

local volume_slider = {}
newflat.widget.audio.slider:init({})
volume_slider.widget = newflat.widget.audio.slider()

local audio_toggle = {}
newflat.widget.audio.toggle:init({audio=volume.widget})
audio_toggle.widget = newflat.widget.audio.toggle()
audio_toggle.buttons = awful.util.table.join(
	awful.button({}, 1, function () newflat.widget.audio.toggle:toggle({audio=volume.widget}) end),
	awful.button({}, 4, function () newflat.widget.audio.toggle:toggle({audio=volume.widget}) end),
	awful.button({}, 5, function () newflat.widget.audio.toggle:toggle({audio=volume.widget}) end)
)

-- Brightness control
--------------------------------------------------------------------------------
local brightness_slider = {}
newflat.widget.brightness.slider:init({})
brightness_slider.widget = newflat.widget.brightness.slider()

-- PA volume control
--------------------------------------------------------------------------------

local refresher = {}
newflat.widget.refresher.toggle:init({})
refresher.widget = newflat.widget.refresher.toggle()
refresher.buttons = awful.util.table.join(
	awful.button({}, 1, function () newflat.widget.refresher.toggle:toggle() end),
	awful.button({}, 4, function () newflat.widget.refresher.toggle:toggle() end),
	awful.button({}, 5, function () newflat.widget.refresher.toggle:toggle() end)
)

-- Settings control
--------------------------------------------------------------------------------
local settings = {}
newflat.widget.settings.menu:init({
	env = env, microphone = microphone_toggle, microphone_slider = microphone_slider, volume_slider=volume_slider, volume = audio_toggle, brightness_slider=brightness_slider, refresher=refresher,
 })
settings.widget = newflat.widget.settings.menu()

settings.buttons = awful.util.table.join(
	awful.button({}, 1, function ()  newflat.widget.refresher.toggle:update() newflat.widget.settings.menu:toggle_menu() end),
	awful.button({}, 4, function() volume.widget:change_volume({ show_notify = true })              newflat.widget.audio.slider:toggle() end),
	awful.button({}, 5, function() volume.widget:change_volume({ show_notify = true, down = true }) newflat.widget.audio.slider:toggle() end),
	awful.button({}, 2, function() volume.widget:mute({show_notify = true}) 												newflat.widget.audio.slider:toggle() end)
	-- awful.button({}, 4, function () newflat.widget.settings:toggle()      end),
	-- awful.button({}, 5, function () newflat.widget.settings:toggle(true)  end)
)
--volume.widget = newflat.widget.audio.pulse(nil, { widget = redflat.gauge.audio.red.new })

-- activate player widget
-- newflat.widget.player.player:init({ name = env.player })

-- volume.buttons = awful.util.table.join(
-- 	awful.button({}, 4, function() volume.widget:change_volume()                end),
-- 	awful.button({}, 5, function() volume.widget:change_volume({ down = true }) end),
-- 	awful.button({}, 2, function() volume.widget:mute()                         end),
-- 	awful.button({}, 3, function() redflat.float.player:show()                  end),
-- 	awful.button({}, 1, function() redflat.float.player:action("PlayPause")     end),
-- 	awful.button({}, 8, function() redflat.float.player:action("Previous")      end),
-- 	awful.button({}, 9, function() redflat.float.player:action("Next")          end)
-- )

-- Keyboard layout indicator
--------------------------------------------------------------------------------
-- local kbindicator = {}
-- redflat.widget.keyboard:init({ "English", "Russian" })
-- kbindicator.widget = redflat.widget.keyboard()

-- kbindicator.buttons = awful.util.table.join(
-- 	awful.button({}, 1, function () redflat.widget.keyboard:toggle_menu() end),
-- 	awful.button({}, 4, function () redflat.widget.keyboard:toggle()      end),
-- 	awful.button({}, 5, function () redflat.widget.keyboard:toggle(true)  end)
-- )

local tray_toggle = {}
newflat.widget.tray.systoggler:init({})
tray_toggle.widget = newflat.widget.tray.systoggler()

tray_toggle.buttons = awful.util.table.join(
	awful.button({}, 1, function () newflat.widget.tray.systoggler:toggle() end)
)

-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = { widget = {}, buttons = {}, icon = {} }

-- -- icons
-- sysmon.icon.battery = redflat.util.table.check(beautiful, "battery.battery")
-- sysmon.icon.charging = redflat.util.table.check(beautiful, "battery.charging")

-- battery
sysmon.widget.battery = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.bat(10), arg = "BAT0" },
	{ timeout = 1, widget = newflat.widget.icon.single, monitor = { is_vertical = true, icon = sysmon.icon.battery } }
)


sysmon.icon.battery = redflat.util.table.check(beautiful, "battery.battery")

sysmon.icon.full = redflat.util.table.check(beautiful, "battery.full")
sysmon.icon.unknown = redflat.util.table.check(beautiful, "battery.unknown")
sysmon.icon.charged = redflat.util.table.check(beautiful, "battery.charged")
sysmon.icon.charging = redflat.util.table.check(beautiful, "battery.charging")   
sysmon.icon.discharging = redflat.util.table.check(beautiful, "battery.discharging")

-- awesome.connect_signal("charging_status_change", function()
--     -- Update the widget content or properties here
--     sysmon.widget.battery = redflat.widget.sysmon(
-- 	{ func = redflat.system.pformatted.bat(10), arg = "BAT0" },
-- 	{ timeout = 1, widget = newflat.widget.icon.single, monitor = { is_vertical = true, icon = { full = sysmon.icon.battery, unknown = sysmon.icon.battery, charged = sysmon.icon.battery, charging = sysmon.icon.charging, discharging = sysmon.icon.battery} } }
-- )
-- end)

-- battery
sysmon.widget.battery = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.bat(10), arg = "BAT0" },
	{ timeout = 1, widget = newflat.widget.icon.single, monitor = { is_vertical = true, icon = { full = sysmon.icon.battery, unknown = sysmon.icon.battery, charged = sysmon.icon.battery, charging = sysmon.icon.charging, discharging = sysmon.icon.battery} } }
)







-- -- battery
-- sysmon.widget.battery = redflat.widget.sysmon(
-- 	{ func = redflat.system.pformatted.bat(25), arg = "BAT0" },
-- 	{ timeout = 60, widget = redflat.gauge.monitor.dash }
-- )

-- -- network speed
-- sysmon.widget.network = redflat.widget.net(
-- 	{
-- 		interface = "wlp60s0",
-- 		speed = { up = 6 * 1024^2, down = 6 * 1024^2 },
-- 		autoscale = false
-- 	},
-- 	{ timeout = 2, widget = redflat.gauge.icon.double }
-- )
--
-- -- CPU usage
-- sysmon.widget.cpu = redflat.widget.sysmon(
-- 	{ func = redflat.system.pformatted.cpu(80) },
-- 	{ timeout = 2, widget = redflat.gauge.monitor.dash }
-- )
--
-- sysmon.buttons.cpu = awful.util.table.join(
-- 	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
-- )
--
-- -- RAM usage
-- sysmon.widget.ram = redflat.widget.sysmon(
-- 	{ func = redflat.system.pformatted.mem(70) },
-- 	{ timeout = 10, widget = redflat.gauge.monitor.dash }
-- )
--
-- sysmon.buttons.ram = awful.util.table.join(
-- 	awful.button({ }, 1, function() redflat.float.top:show("mem") end)
-- )


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------

-- aliases for setup
local al = awful.layout.layouts
local sharedtags = require("sharedtags")
tags = {}
tags = sharedtags({
    { name = "1", layout = al[5] },
    { name = "2", layout = al[5] },
    { name = "3", layout = al[2] },
    { name = "4", layout = al[4] },
	{ name = "5", layout = al[5] },
	{ name = "6", screen = 2, layout = al[3] },
})


-- local startscreen = awful.screen.getbycoord(0,0)
-- local startscreen =  screen[startscreen]

-- while( startscreen ~= nil )
-- do
-- 	if startscreen == screen.primary then
-- 		tags[#tags + 1] = sharedtags:add({ name = #tags, screen = startscreen.index, layout = al[5] })
-- 		tags[#tags + 1] = sharedtags:add({ name = #tags, screen = startscreen.index, layout = al[5] })
-- 		tags[#tags + 1] = sharedtags:add({ name = #tags, screen = startscreen.index, layout = al[2] })
-- 		tags[#tags + 1] = sharedtags:add({ name = #tags, screen = startscreen.index, layout = al[4] })
-- 		tags[#tags + 1] = sharedtags:add({ name = #tags, screen = startscreen.index, layout = al[5] })
-- 	else
-- 		tags[#tags + 1] = sharedtags:add({ name = #tags, screen = startscreen.index, layout = al[5] })
-- 	end
-- 	startscreen = startscreen:get_next_in_direction("right")
-- end



local workarea = { width = 0, height = 0}

-- setup
awful.screen.connect_for_each_screen(
	function(s)
		workarea.width= workarea.width + s.workarea.width
		awful.spawn("setbg")
		if s == screen.primary then
			-- wallpaper
			-- env.wallpaper(s)

			-- tags
			--awful.tag({ "Main", "Full", "Edit", "Read", "Free", "Vbox" }, s, { al[5], al[5], al[2], al[4], al[5], al[3] })
			--sharedtags.viewonly(tags[4], s)
			-- taglist widget
			taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

			-- tasklist widget
			tasklist[s] = newflat.widget.tasklist.tasklist({ screen = s, buttons = tasklist.buttons }, tasklist.style)


			-- panel wibox
			s.panel = awful.wibar({ position = "top", screen = s, height = beautiful.panel_height or 36 })

			s.systray = wibox.widget.systray()
			s.systray.visible = false
			-- beautiful.systray_icon_spacing = 10
			-- s.my_sys = wibox.container.margin(s.systray, 10, 10, 5, 5)

			-- add widgets to the wibox
			s.panel:setup {
				layout = wibox.layout.align.horizontal,
				expand = "none",
				{ -- left widgets
					layout = wibox.layout.fixed.horizontal,

					env.wrapper(tasklist[s], "tasklist"),
					-- separator,
				},
				{ -- middle widget
					layout = wibox.layout.align.horizontal,
					expand = "outside",
					nil,
					env.wrapper(taglist[s], "taglist"),
				},
				{ -- right widgets
					layout = wibox.layout.fixed.horizontal,
					env.wrapper(s.systray, "systray"),
					env.wrapper(tray_toggle.widget, "tray_toggle", tray_toggle.buttons),
					-- separator,
					-- env.wrapper(kbindicator.widget, "keyboard", kbindicator.buttons),

					env.wrapper(sysmon.widget.battery, "battery"),

					env.wrapper(notifications.widget, "notifications", notifications.buttons),

					env.wrapper(settings.widget, "settings", settings.buttons),
					-- env.wrapper(s.info_center_toggle, "info_center", info_center_toggle.buttons),



					-- env.wrapper(s.control_center_toggle, "control_center", control_center_toggle.buttons),

					env.wrapper(textclock.widget, "textclock"),
					-- separator,
					-- env.wrapper(microphone.widget, "microphone", microphone.buttons),
					-- separator,
					-- env.wrapper(volume.widget, "volume", volume.buttons),
					-- separator,
					-- env.wrapper(sysmon.widget.network, "network"),
					-- separator,
					-- env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
					-- env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),

					-- separator,
					--env.wrapper(tray.widget, "tray", tray.buttons),
				},
			}
		else
			workarea.width= workarea.width + s.workarea.width
			-- wallpaper
			-- env.wallpaper(s)
			-- awful.spawn("setbg")
			-- tags
			--awful.tag({ "Main", "Full", "Edit", "Read", "Free", "Vbox" }, s, { al[5], al[5], al[2], al[4], al[5], al[3] })
			--sharedtags.viewonly(tags[4], s)
			-- taglist widget
			taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

			-- tasklist widget
			tasklist[s] = newflat.widget.tasklist.tasklist({ screen = s, buttons = tasklist.buttons }, tasklist.style)


			-- panel wibox
			s.panel = awful.wibar({ position = "top", screen = s, height = beautiful.panel_height or 36 })



			-- add widgets to the wibox
			s.panel:setup {
				layout = wibox.layout.align.horizontal,
				expand = "none",
				{ -- left widgets
					layout = wibox.layout.fixed.horizontal,

					env.wrapper(tasklist[s], "tasklist"),
					-- separator,
				},
				{ -- middle widget
					layout = wibox.layout.align.horizontal,
					expand = "outside",
					nil,
					env.wrapper(taglist[s], "taglist"),
				},
				{ -- right widgets
					layout = wibox.layout.fixed.horizontal,
					env.wrapper(textclock.widget, "textclock"),
				},
			}
		end
	end
)

require('newflat.widget.notifications.notifications')


-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
local edges = require("color.pudding.edges-config") -- load file with edges configuration
edges:init({workarea=workarea})


-- Log out screen
-----------------------------------------------------------------------------------------------------------------------
local logout = require("color.pudding.logout-config")
logout:init()


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local appkeys = require("color.pudding.appkeys-config") -- load file with application keys sheet

local hotkeys = require("color.pudding.keys-config") -- load file with hotkeys configuration
-- hotkeys:init({ env = env, menu = mymenu.mainmenu, appkeys = appkeys, volume = volume.widget })
hotkeys:init({
	env = env, menu = mymenu.mainmenu, appkeys = appkeys, volume = volume.widget,  microphone = microphone.widget,
 })

-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("color.pudding.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
-- local titlebar = require("color.pudding.titlebar-config") -- load file with titlebar configuration
-- titlebar:init()

-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("color.pudding.signals-config") -- load file with signals configuration
signals:init({ env = env })


-- Autostart user applications
-- --------------------------------------------------------------------------------------------------------------------
if redflat.startup.is_startup then
	local autostart = require("color.pudding.autostart-config") -- load file with autostart application list
	autostart.run()
end


-- Refresh
awful.spawn.with_shell([[xwallpaper --zoom $(gsettings get org.gnome.desktop.background picture-uri | sed "s|'||g" | sed "s|file://||")]])
