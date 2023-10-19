-----------------------------------------------------------------------------------------------------------------------
--                                     NewFlat Settingsmenu widget                                      --
-----------------------------------------------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local awful = require("awful")
local beautiful = require("beautiful")

local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local redtip = require("redflat.float.hotkeys")

local separator = require("redflat.gauge.separator")
local wibox = require("wibox")

local newflat = require("newflat")
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local menu = { mt = {}, keys = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		keytip          = { geometry = { width = 400 }, exit = false },
		icon           = redutil.base.placeholder(),
		micon          = { blank = redutil.base.placeholder({ txt = " " }),
						 close = redutil.base.placeholder({ txt = "x" }) },
		menu           = { color = { right_icon = "#a0a0a0" } },
		layout_color   = { "#a0a0a0", "#b1222b", "#ff0000" },
		fallback_color = "#32882d",
		titleline            = { font = "Sans 16 bold", height = 30 },
		hide_timeout = 0,
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.settings") or {})
end



local function state_line_construct(state_icons, setup_layout, style)
	local stateboxes = {}

	for i, v in ipairs(state_icons) do
		-- create widget
		stateboxes[i] = svgbox(v.icon)
		stateboxes[i]:set_forced_width(20)
		stateboxes[i]:set_forced_height(20)

		-- set widget in line
		local l = wibox.layout.align.horizontal()
		l:set_expand("outside")
		l:set_second(stateboxes[i])
		setup_layout:add(l)

		-- set mouse action
		stateboxes[i]:buttons(awful.util.table.join(awful.button({}, 1,
			function()
				v.action()
				stateboxes[i]:set_color(v.indicator(last.client) and "#ff0000" or "#00ff00")
			end
		)))
	end

	return stateboxes
end

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------

-- key bindings
menu.keys.action = {
	{
		{}, "Escape", function() menu:hide(true) end,
		{ description = "Exit", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() redtip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
}

menu.keys.all = awful.util.table.join(menu.keys.action)


-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function menu:init(args)

	-- initialize vars
	style = redutil.table.merge(default_style(), style or {})
	local volume = args.volume
	local microphone = args.microphone
	local volume_slider = args.volume_slider
	local microphone_slider = args.microphone_slider
	local brightness_slider = args.brightness_slider
	local refresher = args.refresher
	local env = args.env
	self.layouts = {}
	self.style = style
	self.objects = {}

	self.keytip = style.keytip
	self:set_keys()

	-- tooltip
	-- self.tp = tooltip({ objects = {} }, style.tooltip)


	-- layouts
	local stateline_horizontal = wibox.layout.flex.horizontal()
	local stateline_vertical = wibox.layout.align.vertical()
	stateline_vertical:set_second(stateline_horizontal)
	stateline_vertical:set_expand("outside")
	local stateline = wibox.container.constraint(stateline_vertical, "exact", nil, style.titleline.height)

	local airplane = {}
	newflat.widget.airplane.toggle:init({})
	airplane.widget = newflat.widget.airplane.toggle()
	airplane.buttons = awful.util.table.join(
		awful.button({}, 1, function () newflat.widget.airplane.toggle:toggle({}) end),
		awful.button({}, 3, function () newflat.widget.airplane.toggle:toggle({}) end),
		awful.button({}, 4, function () newflat.widget.airplane.toggle:toggle({}) end),
		awful.button({}, 5, function () newflat.widget.airplane.toggle:toggle({}) end)
	)
	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	l:set_second(env.wrapper(airplane.widget, "settings_airplane_mode", airplane.buttons))
	stateline_horizontal:add(l)

	local bluetooth = {}
	newflat.widget.bluetooth.toggle:init({})
	bluetooth.widget = newflat.widget.bluetooth.toggle()
	bluetooth.buttons = awful.util.table.join(
		awful.button({}, 1, function () newflat.widget.bluetooth.toggle:toggle({}) end),
		awful.button({}, 3, function () newflat.widget.bluetooth.toggle:toggle({}) end),
		awful.button({}, 4, function () newflat.widget.bluetooth.toggle:toggle({}) end),
		awful.button({}, 5, function () newflat.widget.bluetooth.toggle:toggle({}) end)
	)
	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	l:set_second(env.wrapper(bluetooth.widget, "settings_bluetooth", bluetooth.buttons))
	stateline_horizontal:add(l)

	-- local redshift = {}
	-- newflat.widget.redshift.toggle:init({})
	-- redshift.widget = newflat.widget.redshift.toggle()
	-- redshift.buttons = awful.util.table.join(
	-- 	awful.button({}, 1, function () newflat.widget.redshift.toggle:toggle({}) end),
	-- 	awful.button({}, 3, function () newflat.widget.redshift.toggle:toggle({reverse = true}) end),
	-- 	awful.button({}, 4, function () newflat.widget.redshift.toggle:toggle({}) end),
	-- 	awful.button({}, 5, function () newflat.widget.redshift.toggle:toggle({reverse = true}) end)
	-- )
	-- local l = wibox.layout.align.horizontal()
	-- l:set_expand("outside")
  	-- l:set_second(env.wrapper(redshift.widget, "settings_redshift", redshift.buttons))
	-- stateline_horizontal:add(l)



	local notifications_toggle = {}
	newflat.widget.notifications.toggle:init({})
	notifications_toggle.widget = newflat.widget.notifications.toggle()
	notifications_toggle.buttons = awful.util.table.join(
		awful.button({}, 1, function () newflat.widget.notifications.toggle:toggle({}) end),
		awful.button({}, 3, function () newflat.widget.notifications.toggle:toggle({}) end),
		awful.button({}, 4, function () newflat.widget.notifications.toggle:toggle({}) end),
		awful.button({}, 5, function () newflat.widget.notifications.toggle:toggle({}) end)
	)

	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	-- l:set_second(env.wrapper(require('newflat.widget.dont-disturb'), "settings_dont_disturb"))
	local bla = wibox.container.margin(notifications_toggle.widget, 0, 0, 2, 0)
	l:set_second(env.wrapper(bla, "notifications_toggle", notifications_toggle.buttons))
	stateline_horizontal:add(l)

	-- local l = wibox.layout.align.horizontal()
	-- l:set_expand("outside")
  	-- l:set_second(env.wrapper(volume.widget, "settings_volume", volume.buttons))
	-- stateline_horizontal:add(l)

	-- local l = wibox.layout.align.horizontal()
	-- l:set_expand("outside")
	-- l:set_second(env.wrapper(microphone.widget, "settings_microphone", microphone.buttons))
	-- stateline_horizontal:add(l)


	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	l:set_second(env.wrapper(refresher.widget, "settings_refresher", refresher.buttons))
	stateline_horizontal:add(l)


	local classbox = wibox.widget.textbox()
	classbox:set_text("Control Center")
	classbox:set_font(style.titleline.font)
	classbox:set_align ("center")

	local classline = wibox.container.constraint(classbox, "exact", nil, style.titleline.height)


	local menusep = { widget = separator.horizontal(style.separator) }


	-- local brightness = wibox.container.margin(brightness_slider, 15, 15, 5, 5)
	-- local brightness = wibox.container.constraint(brightness, "exact", 350, 40)

	-- local volume = wibox.container.margin(volume_slider, 15, 15, 5, 5)
	-- local volume = wibox.container.constraint(volume, "exact", 350, 40)

	-- local microphone = wibox.container.margin(microphone_slider, 15, 15, 5, 5)
	-- local microphone = wibox.container.constraint(microphone, "exact", 350, 40)






	local redshift = {}
	newflat.widget.redshift.toggle:init({})
	redshift.widget = newflat.widget.redshift.toggle()
	redshift.buttons = awful.util.table.join(
		awful.button({}, 1, function () newflat.widget.redshift.toggle:toggle({}) end),
		awful.button({}, 3, function () newflat.widget.redshift.toggle:toggle({reverse = true}) end),
		awful.button({}, 4, function () newflat.widget.redshift.toggle:toggle({}) end),
		awful.button({}, 5, function () newflat.widget.redshift.toggle:toggle({reverse = true}) end)
	)




	local brightness_stateline_horizontal = wibox.layout.fixed.horizontal()
	local brightness_stateline_vertical = wibox.layout.align.vertical()
	brightness_stateline_vertical:set_second(brightness_stateline_horizontal)
	brightness_stateline_vertical:set_expand("outside")
	local brightness_stateline = wibox.container.constraint(brightness_stateline_vertical, "exact", nil, style.titleline.height + 10)

	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	l:set_second(wibox.container.margin(env.wrapper(redshift.widget, "settings_redshift", redshift.buttons), 5, 0, 5, 5))
	brightness_stateline_horizontal:add(l)

	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	local brightness = wibox.container.margin(brightness_slider, 5, 15, 5, 5)

	l:set_second(brightness)
	brightness_stateline_horizontal:add(l)















	local volume_stateline_horizontal = wibox.layout.fixed.horizontal()
	local volume_stateline_vertical = wibox.layout.align.vertical()
	volume_stateline_vertical:set_second(volume_stateline_horizontal)
	volume_stateline_vertical:set_expand("outside")
	local volume_stateline = wibox.container.constraint(volume_stateline_vertical, "exact", nil, style.titleline.height + 10)

	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	l:set_second(wibox.container.margin(env.wrapper(volume.widget, "settings_volume", volume.buttons), 5, 0, 5, 5))
	volume_stateline_horizontal:add(l)

	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	-- local microphone = wibox.container.margin(microphone_slider, 5, 45, 5, 5)
	local volume = wibox.container.margin(volume_slider, 5, 15, 5, 5)

	-- local microphone = wibox.container.constraint(microphone, "exact", 350, 40)
	l:set_second(volume)
	volume_stateline_horizontal:add(l)


	
	local microphone_stateline_horizontal = wibox.layout.fixed.horizontal()
	local microphone_stateline_vertical = wibox.layout.align.vertical()
	microphone_stateline_vertical:set_second(microphone_stateline_horizontal)
	microphone_stateline_vertical:set_expand("outside")
	-- local microphone_stateline = wibox.container.margin(wibox.container.constraint(microphone_stateline_vertical, "exact", nil, style.titleline.height), 0, 0, 5, 5)
	local microphone_stateline = wibox.container.constraint(microphone_stateline_vertical, "exact", nil, style.titleline.height + 10)

	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	l:set_second(wibox.container.margin(env.wrapper(microphone.widget, "settings_microphone", microphone.buttons), 5, 0, 5, 5))
	microphone_stateline_horizontal:add(l)

	local l = wibox.layout.align.horizontal()
	l:set_expand("outside")
	-- local microphone = wibox.container.margin(microphone_slider, 5, 45, 5, 5)
	local microphone = wibox.container.margin(microphone_slider, 5, 15, 5, 5)

	-- local microphone = wibox.container.constraint(microphone, "exact", 350, 40)
	l:set_second(microphone)
	microphone_stateline_horizontal:add(l)


	-- local microphone = wibox.container.margin(microphone_slider, 15, 15, 5, 5)
	-- local microphone = wibox.container.constraint(microphone, "exact", 350, 40)



	menu_items = {
		{ widget = classline },
		menusep,
		-- {widget = brightness},
		{widget = brightness_stateline},
		-- {widget = volume},
		{widget = volume_stateline},
		{widget = microphone_stateline},
		-- {widget = microphone},
		menusep,
		{ widget = stateline, focus = true }
	}


	-- menu:popup(style)



	-- Create menu
	------------------------------------------------------------
	self.menu = newflat.menu({
		theme = style.menu,
		items = menu_items,
	})

end

-- Set user hotkeys
-----------------------------------------------------------------------------------------------------------------------
function menu:set_keys(keys, layout)
	layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then self.keys.all = awful.util.table.join(self.keys.action) end
	end

	-- self.tip = awful.util.table.join(self.keys.all)

	newflat.menu:set_keys(keys, "move")
	self.tip = awful.util.table.join(self.keys.all)
end

-- Show layout menu
-----------------------------------------------------------------------------------------------------------------------
function menu:toggle_menu()
	if not self.menu then return end

	if self.menu.wibox.visible then
		menu:hide()
	else
		menu:show()
	end
end

-- Show menu widget
-----------------------------------------------------------------------------------------------------------------------
function menu:show(is_empty_call)

	awful.placement.under_mouse(self.menu.wibox)
	awful.placement.no_offscreen(self.menu.wibox)
	self.menu:show({ coords = { x = self.menu.wibox.x, y = self.menu.wibox.y } })

	if self.hidetimer and self.hidetimer.started then self.hidetimer:stop() end

	redtip:set_pack(
		"Settings Menu", self.tip, self.keytip.column, self.keytip.geometry,
		self.keytip.exit and function() menu:hide(true) end
	)
end

-- Hide menu widget
-----------------------------------------------------------------------------------------------------------------------
function menu:hide(is_empty_call)

	-- if not self.wibox then self:init() end
	-- if not self.menu.wibox.visible then return end
	-- self.menu.wibox.visible = false
	self.menu:hide()
	redtip:remove_pack()
	if self.hidetimer and self.hidetimer.started then self.hidetimer:stop() end
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function menu.new(style)

	style = style or {}
	if not menu.menu then menu:init({}) end

	local widg = svgbox(style.icon or menu.style.icon)
	widg:set_color(menu.style.layout_color[1])
	table.insert(menu.objects, widg)

	return widg
end

-- Config metatable to call menu module as function
-----------------------------------------------------------------------------------------------------------------------
function menu.mt:__call(...)
	return menu.new(...)
end

return setmetatable(menu, menu.mt)
