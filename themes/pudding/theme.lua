-----------------------------------------------------------------------------------------------------------------------
--                                                  Green theme                                                      --
-----------------------------------------------------------------------------------------------------------------------
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")


local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")

-- Fonts
------------------------------------------------------------
theme.fonts = {
	main     = "Ubuntu 13",      -- main font
	menu     = "Ubuntu 13",      -- main menu font
	tooltip  = "Ubuntu 13",      -- tooltip font
	notify   = "Ubuntu bold 14",   -- redflat notify popup font
	clock    = "Ubuntu Medium 12",   -- textclock widget font
	qlaunch  = "Ubuntu bold 14",   -- quick launch key label font
	logout   = "Ubuntu bold 14",   -- logout screen labels
	keychain = "Ubuntu bold 16",   -- key sequence tip font
	title    = "Ubuntu bold 13", -- widget titles font
	tiny     = "Ubuntu bold 10", -- smallest font for widgets
	titlebar = "Ubuntu bold 11", -- client titlebar font
	logout   = {
		label   = "Ubuntu bold 14", -- logout option labels
		counter = "Ubuntu bold 24", -- logout counter
	},
	hotkeys  = {
		main  = "Ubuntu 14",             -- hotkeys helper main font
		key   = "Ubuntu Mono 16", -- hotkeys helper key font (use monospace for align)Andale Mono
		--key   = "Iosevka Term Light 14", -- hotkeys helper key font (use monospace for align)
		title = "Ubuntu bold 16",        -- hotkeys helper group title font
	},
	player   = {
		main = "Ubuntu bold 13", -- player widget main font
		time = "Ubuntu bold 15", -- player widget current time font
	},
	-- very custom calendar fonts
	calendar = {
		clock = "Ubuntu bold 28", date = "Ubuntu 16", week_numbers = "Ubuntu 12", weekdays_header = "Ubuntu 12",
		days  = "Ubuntu 14", default = "Ubuntu 14", focus = "Ubuntu 12 Bold", controls = "Ubuntu bold 16"
	},
}
theme.cairo_fonts = {
	tag         = { font = "Ubuntu", size = 16, face = 0 }, -- tag widget font
	appswitcher = { font = "Ubuntu", size = 22, face = 1 }, -- appswitcher widget font
	navigator   = {
		title = { font = "Ubuntu", size = 28, face = 1, slant = 0 }, -- window navigation title font
		main  = { font = "Ubuntu", size = 22, face = 1, slant = 0 }  -- window navigation  main font
	},

	desktop = {
		textbox = { font = "Ubuntu", size = 24, face = 1 },
	},
}

-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
-- theme.color = {
-- 	-- main colors
-- 	main      = "#D33C3C",
-- 	gray      = "#575757",
-- 	bg        = "#161616",
-- 	bg_second = "#181818",
-- 	wibox     = "#202020",
--
-- 	--wibox     = "#1e1e1e99",
-- 	icon      = "#a0a0a0",
-- 	--icon      = "#ffffffde",
--
-- 	text      = "#aaaaaa",
-- 	--text      = "#ffffffde",
-- 	urgent    = "#a21e17",
-- 	highlight = "#e0e0e0",
-- 	border    = "#404040",
--
-- 	-- secondary colors
-- 	shadow1   = "#141414",
-- 	shadow2   = "#313131",
-- 	shadow3   = "#1c1c1c",
-- 	shadow4   = "#767676",
--
-- 	button    = "#575757",
-- 	pressed   = "#404040",
--
-- 	desktop_gray = "#404040",
-- 	desktop_icon = "#606060",
-- }
theme.color = {
	-- main colors
	-- main      = "#EBCB8B",
	main      = "#5294e2",
	secondary = "#B48EAD",
	gray      = "#575757",
	bg        = "#323842",
	bg_second = "#3a404c",
  	wibox     = "#282c34",

	--wibox     = "#1e1e1e99",
	icon      = "#bbc2cf",
	--icon      = "#ffffffde",

	text      = "#bbc2cf",
	--text      = "#ffffffde",
	urgent    = "#BF616A",
	highlight = "#282C34",
	border    = "#404040",

	-- secondary colors
	shadow1   = "#141414",
	shadow2   = "#313131",
	shadow3   = "#1c1c1c",
	shadow4   = "#767676",

	button    = "#575757",
	pressed   = "#404040",

	desktop_gray = "#404040",
	desktop_icon = "#606060",
}

-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/pudding"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 33 -- panel height
-- theme.wallpaper    = theme.path .. "/wallpaper/spine-wallpaper-2560x1440.jpg"
theme.border_width        = dpi(1)  -- window border width
theme.border_color					= "#21242b"
theme.useless_gap         = 4  -- useless gap


theme.notification = { timeout = { normal, low, critical } }
theme.notification.timeout.normal = 6
theme.notification.timeout.low = 6
theme.notification.timeout.critical = 0
-- Fonts
------------------------------------------------------------
theme.cairo_fonts.desktop.textbox = { font = "Germania One", size = 24, face = 0 }


-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

-- Desktop widgets placement
--------------------------------------------------------------------------------
theme.desktop.grid = {
	width  = { 480, 480, 480 },
	height = { 180, 146, 146, 132, 17 },
	edge   = { width = { 80, 80 }, height = { 50, 50 } }
}

theme.desktop.places = {
	netspeed = { 1, 1 },
	ssdspeed = { 2, 1 },
	hddspeed = { 3, 1 },
	cpumem   = { 1, 2 },
	transm   = { 1, 3 },
	disks    = { 1, 4 },
	thermal  = { 1, 5 }
}

-- Desktop widgets
--------------------------------------------------------------------------------
-- individual widget settings doesn't used by redflat module
-- but grab directly from rc-files to rewrite base style
theme.individual.desktop = { speedmeter = {}, multimeter = {}, multiline = {}, singleline = {} }

theme.desktop.line_height = 17

-- Lines (common part)
theme.desktop.common.pack.lines.label = { width = 60, draw = "by_width" }
theme.desktop.common.pack.lines.text  = { width = 80, draw = "by_edges" }
theme.desktop.common.pack.lines.gap   = { text = 14, label = 14 }
theme.desktop.common.pack.lines.line  = { height = theme.desktop.line_height }

-- Speedmeter (base widget)
--theme.desktop.speedmeter.normal.label = { height = theme.desktop.line_height }
theme.desktop.speedmeter.normal.images = { theme.path .. "/desktop/up.svg", theme.path .. "/desktop/down.svg" }

-- Speedmeter drive (individual widget)
theme.individual.desktop.speedmeter.drive = {
	unit   = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } },
}

-- Multimeter (base widget)
theme.desktop.multimeter.icon           = { image = false }
theme.desktop.multimeter.height.lines   = 54
theme.desktop.multimeter.height.upright = 70
theme.desktop.multimeter.upbar          = { width = 32, chunk = { num = 10, line = 3 }, shape = "plain" }
theme.desktop.multimeter.lines.show     = { label = true, tooltip = false, text = true }

-- Multimeter cpu and ram (individual widget)
theme.individual.desktop.multimeter.cpumem = {
	labels = { "RAM", "SWAP" },
}

-- Multimeter transmission info (individual widget)
theme.individual.desktop.multimeter.transmission = {
	labels = { "SEED", "DNLD" },
	unit   = { { "KB", -1 }, { "MB", 1024^1 } },
}

-- Multilines disks (individual widget)
theme.individual.desktop.multiline.disks = {
	unit  = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
	lines = { show = { text = false } },
}

-- Singleline temperature (individual widget)
theme.individual.desktop.singleline.thermal = {
	lbox = { draw = "by_width", width = 45 },
	rbox = { draw = "by_edges", width = 52 },
	iwidth = 125,
	icon = theme.path .. "/desktop/fire.svg",
	unit = { { "°C", -1 } },
}

-- theme.titlebar.icon = {
-- 	color = theme.color, -- colors (main used)
--
-- 	-- icons list
-- 	list = {
-- 		focus     = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/focus.svg",
-- 		floating  = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/floating.svg",
-- 		ontop     = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/ontop.svg",
-- 		below     = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/below.svg",
-- 		sticky    = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/pin.svg",
-- 		maximized = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/circle.svg",
-- 		minimized = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/circle.svg",
-- 		close     = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/circle.svg",
-- 		menu      = awful.util.get_configuration_dir() .. "themes/colorless/titlebar/menu.svg",
--
-- 		--unknown   = self.icon.unknown, -- this one used as fallback
-- 	}
-- }
-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for panel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	textclock   = { 10, 10, 9, 7 },
	volume      = { 12, 10, 3, 3 },
	microphone  = { 10, 10, 6, 6 },
	network     = { 6, 6, 8, 8 },
	cpu         = { 10, 2, 8, 8 },
	ram         = { 2, 2, 8, 8 },
	battery     = { 10, 10, 8, 8 },
	keyboard    = { 10, 10, 8, 8 },
	mail        = { 10, 10, 5, 5 },
	tray        = { 10, 12, 6, 6 },
	tray_toggle = { 10, 10, 6, 6 },
	taglist     = { 3, 3, 0, 0 },
	tasklist    = { 14, 0, 0, 0 }, -- centering tasklist widget
	info_center = { 10, 12, 8, 8 },
	control_center = { 10, 12, 8, 8 },
	tray_toggle = { 10, 12, 8, 8 },
	notifications ={ 10, 12, 8, 8 },
	settings ={ 10, 12, 8, 8 },
	systray	= { 10, 10, 5, 5 },
	settings_volume      = { 10, 10, 4, 6 },
	notifications_toggle      = { 10, 10, 4, 6 },
	settings_microphone      = { 10, 10, 5, 7 },
	settings_dont_disturb      = { 10, 10, 6, 7 },
	settings_redshift      = { 10, 10, 2, 6 },
	settings_bluetooth      = { 10, 10, 4, 5 },
	settings_airplane_mode      = { 10, 10, 4, 5 },
	settings_refresher      = { 10, 10, 4, 5 },
}

-- Various widgets style tuning
------------------------------------------------------------


-- Tasklist
------------------------------------------------------------
theme.gauge.task.blue.width        = 90
theme.gauge.task.blue.point.width  = 90
theme.widget.tasklist.char_digit = 7
theme.widget.tasklist.task = theme.gauge.task.blue
theme.widget.tasklist.need_group = false
theme.widget.tasklist.tasktip.timeout      = 0.0
theme.widget.tasklist.tasktip.margin = { 8, 8, 3, 3 }

-- Dotcount (used in minitray widget)
------------------------------------------------------------
theme.gauge.graph.dots = {
	column_num   = { 3, 3 },  -- amount of dot columns (min/max)
	row_num      = 3,         -- amount of dot rows
	dot_size     = 4,         -- dots size
	dot_gap_h    = 4,         -- horizontal gap between dot (with columns number it'll define widget width)
}
-- microphone
------------------------------------------------------------
theme.individual.microphone_audio = {
	icon  = { volume = theme.path .. "/widget/microphone2.svg", mute = theme.path .. "/widget/microphone2.svg" },                   -- icons
	step  = 0.05,                                                                      -- icon painting step
	color = { main = theme.color.main, icon = theme.color.icon, mute = theme.color.gray } -- custom colors
}



-- ------------------------------------------------------------
theme.widget.notifications = {
	icon         = awful.util.get_configuration_dir() .. 'newflat/widget/settings/icons/bell.svg',  -- widget icon
	-- close = theme.base2 .. "/titlebar/close.svg",
	micon          = { --blank = redutil.base.placeholder({ txt = " " }),
					 close = awful.util.get_configuration_dir() .. "/themes/colorless/titlebar/close.svg", },         -- some common menu icons


	-- list of colors associated with keyboard layouts
	layout_color = { theme.color.icon, theme.color.main, theme.color.urgent },

	-- redflat menu style (see theme.menu)
	menu = { width  = 350, color  = { right_icon = theme.color.icon }, nohide = true }
}

theme.widget.settings = {
	icon         = awful.util.get_configuration_dir() .. 'newflat/widget/settings/icons/control-center.svg',  -- widget icon
	-- close = theme.base2 .. "/titlebar/close.svg",
	micon          = { --blank = redutil.base.placeholder({ txt = " " }),
					 close = awful.util.get_configuration_dir() .. "/themes/colorless/titlebar/close.svg",
					 airplane = awful.util.get_configuration_dir() .. "/widget/airplane/icons/airplane-mode-off.svg",
					 bluetooth = awful.util.get_configuration_dir() .. "/widget/bluetooth-toggle/icons/bluetooth-off.svg",
					 redshift = awful.util.get_configuration_dir() .. "/widget/blue-light/icons/blue-light-off.svg",
					 disturb = awful.util.get_configuration_dir() .. "/widget/dont-disturb/icons/dont-disturb.svg",
				 },         -- some common menu icons


	-- list of colors associated with keyboard layouts
	layout_color = { theme.color.icon, theme.color.main, "#D3BB3C" },

	-- redflat menu style (see theme.menu)
	menu = { width  = 350, color  = { right_icon = theme.color.icon }, nohide = true }
}

theme.audio = { notify = {} }
theme.audio.notify = {
	color           = { icon = theme.color.icon, wibox = "#252930" },
}

theme.systray_icon_spacing = 10

theme.transparent="#00000000"
theme.background="#202020"


theme.info_center_icon = awful.util.get_configuration_dir() .. 'newflat/widget/settings/icons/bell.svg'
theme.info_center_icon_color = theme.color.icon
theme.info_center_icon2 = awful.util.get_configuration_dir() .. 'newflat/widget/settings/icons/bell.svg'
theme.info_center_icon2_color = "#D3BB3C"

-- theme.control_center_icon = awful.util.get_configuration_dir() .. 'newflat/wiget/settings/icons/control-center.svg'
-- theme.control_center_icon_color = theme.color.icon




-- UI Groups
theme.groups_title_bg = '#ffffff' .. '15'
theme.groups_bg = '#ffffff' .. '10'
-- theme.groups_radius = dpi(16)

-- UI events
theme.leave_event = transparent
theme.enter_event = '#ffffff' .. '10'
theme.press_event = '#ffffff' .. '15'
theme.release_event = '#ffffff' .. '10'

-- Notification
theme.notification_position = 'top_left'
theme.notification_bg = theme.transparent
theme.notification_margin = dpi(5)
theme.notification_border_width = dpi(0)
theme.notification_border_color = theme.transparent
theme.notification_spacing = dpi(5)
theme.notification_icon_resize_strategy = 'center'
theme.notification_icon_size = dpi(32)







theme.font = 'Inter Regular 10'

theme.background = theme.color.wibox

theme.snap_bg = theme.color.main
theme.snap_shape = gears.shape.rounded_rect
-- function(cr,w,h)
-- 	gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
-- end
theme.snap_border_width = dpi(5)


theme.notification_border_width=dpi(5)
theme.notification_border_color="#ffffff22"

theme.widget.audio_toggle = {
	icon         = { theme.path .. '/widget/mute.svg', theme.path .. '/widget/audio.svg' },
	color = { theme.color.gray, theme.color.main }
}
theme.widget.microphone_toggle = {
	icon         = { theme.path .. '/widget/microphone_mute.svg', theme.path .. '/widget/microphone.svg' },
	color = { theme.color.gray, theme.color.main }
}
theme.widget.notifications_toggle = {
	icon         = { awful.util.get_configuration_dir() .. 'newflat/widget/notifications/icons/bell-off5.svg', awful.util.get_configuration_dir() .. 'newflat/widget/notifications/icons/notify.svg' },
	color = { theme.color.main, theme.color.gray }
}
theme.widget.systoggler = {
	icon         = { awful.util.get_configuration_dir() .. 'newflat/widget/tray/icons/right-arrow.svg', awful.util.get_configuration_dir() .. 'newflat/widget/tray/icons/left-arrow.svg' },
	color 			 = { theme.color.icon }
}
theme.widget.refresher = {
	icon         = { awful.util.get_configuration_dir() .. 'newflat/widget/refresher/icons/reload.svg' },
	color = { theme.color.gray, theme.color.main }
}
theme.widget.redshift = {
	icon         = { awful.util.get_configuration_dir() .. 'newflat/widget/redshift/icons/brightness.svg', awful.util.get_configuration_dir() .. 'newflat/widget/redshift/icons/blue-light.svg', awful.util.get_configuration_dir() .. 'newflat/widget/redshift/icons/dont-disturb.svg'},
	color = { theme.color.gray, theme.color.icon, theme.color.main }
}
theme.widget.airplane = {
	icon         = { awful.util.get_configuration_dir() .. 'newflat/widget/airplane/icons/airplane-mode-off.svg', awful.util.get_configuration_dir() .. 'newflat/widget/airplane/icons/airplane-mode.svg' },
	color = { theme.color.gray, theme.color.main }
}
theme.widget.bluetooth = {
	icon         = { awful.util.get_configuration_dir() .. 'newflat/widget/bluetooth/icons/bluetooth-off.svg', awful.util.get_configuration_dir() .. 'newflat/widget/bluetooth/icons/bluetooth.svg' },
	color = { theme.color.gray, theme.color.main }
}
theme.widget.backlight = {
	-- Step in percentage
	step = 5,
	-- Without value
	get = 'brightnessctl g',
	set = 'brightnessctl s',
	-- With value
	-- up = { 'brightnessctl s ' .. step .. '%-'},
	-- down = { 'brightnessctl s +' .. step .. '%'}
}

-- Hotkeys helper
------------------------------------------------------------
theme.float.hotkeys.geometry = { width = 1500, height = 1000 }
theme.float.hotkeys.heights = { key = 26, title = 32 }
theme.float.hotkeys.border_width  = 2
-- End
-----------------------------------------------------------------------------------------------------------------------
theme.base = awful.util.get_configuration_dir() .. "themes/colorless"

theme.widget.layoutbox.icon = {
	floating          = theme.base .. "/layouts/floating.svg",
	floating1          = theme.base .. "/layouts/floating-1.svg",
	floating2          = theme.base .. "/layouts/floating-2.svg",
	floating3          = theme.base .. "/layouts/floating-3.svg",
	floating4          = theme.base .. "/layouts/floating-4.svg",
	floating5          = theme.base .. "/layouts/floating-5.svg",
	floating6          = theme.base .. "/layouts/floating-6.svg",
	max               = theme.base .. "/layouts/max.svg",
	max1               = theme.base .. "/layouts/max-1.svg",
	max2               = theme.base .. "/layouts/max-2.svg",
	max3               = theme.base .. "/layouts/max-3.svg",
	max4               = theme.base .. "/layouts/max-4.svg",
	max5               = theme.base .. "/layouts/max-5.svg",
	max6               = theme.base .. "/layouts/max-6.svg",
	tile              = theme.base .. "/layouts/tile.svg",
	tile1              = theme.base .. "/layouts/tile-1.svg",
	tile2              = theme.base .. "/layouts/tile-2.svg",
	tile3              = theme.base .. "/layouts/tile-3.svg",
	tile4              = theme.base .. "/layouts/tile-4.svg",
	tile5              = theme.base .. "/layouts/tile-5.svg",
	tile6              = theme.base .. "/layouts/tile-6.svg",
	fairv             = theme.base .. "/layouts/fair.svg",
	fairv1             = theme.base .. "/layouts/fair-1.svg",
	fairv2             = theme.base .. "/layouts/fair-2.svg",
	fairv3             = theme.base .. "/layouts/fair-3.svg",
	fairv4             = theme.base .. "/layouts/fair-4.svg",
	fairv5             = theme.base .. "/layouts/fair-5.svg",
	fairv6             = theme.base .. "/layouts/fair-6.svg",
	usermap           = theme.base .. "/layouts/map.svg",
	usermap1           = theme.base .. "/layouts/map-1.svg",
	usermap2           = theme.base .. "/layouts/map-2.svg",
	usermap3           = theme.base .. "/layouts/map-3.svg",
	usermap4           = theme.base .. "/layouts/map-4.svg",
	usermap5           = theme.base .. "/layouts/map-5.svg",
	usermap6           = theme.base .. "/layouts/map-6.svg",
}
theme.gauge.tag.green.icon = theme.widget.layoutbox.icon


theme.battery = {
	battery    =  awful.util.get_configuration_dir() .. "themes/colored" .. "/widget/battery.svg",
	full    =  awful.util.get_configuration_dir() .. "themes/colored" .. "/widget/battery.svg",
	unknown    =  awful.util.get_configuration_dir() .. "themes/colored" .. "/widget/battery.svg",
	charged    =  awful.util.get_configuration_dir() .. "themes/colored" .. "/widget/battery.svg",
	charging    =  awful.util.get_configuration_dir() .. "themes/colored" .. "/widget/battery-power.svg",
	discharging    =  awful.util.get_configuration_dir() .. "themes/colored" .. "/widget/battery.svg",
}






return theme
