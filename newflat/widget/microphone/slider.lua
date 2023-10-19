-----------------------------------------------------------------------------------------------------------------------
--                                     RedFlat keyboard layout indicator widget                                      --
-----------------------------------------------------------------------------------------------------------------------
-- Indicate and switch keybord layout
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local awful = require("awful")
local beautiful = require("beautiful")

local tooltip = require("redflat.float.tooltip")
local redmenu = require("redflat.menu")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

local wibox = require('wibox')
local gears = require('gears')
local dpi = beautiful.xresources.apply_dpi
local widget_icon_dir = gears.filesystem.get_configuration_dir() .. 'newflat/widget/microphone/icons/'
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local keybd = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon           = redutil.base.placeholder(),
		micon          = { blank = redutil.base.placeholder({ txt = " " }),
						   check = redutil.base.placeholder({ txt = "+" }) },
		menu           = { color = { right_icon = "#a0a0a0" } },
		layout_color   = { "#a0a0a0", "#b1222b" },
		fallback_color = "#32882d",
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.keyboard") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function keybd:init(layouts, style)

	-- initialize vars
	style = redutil.table.merge(default_style(), style or {})
	self.style = style

end

-- Toggle layout
-----------------------------------------------------------------------------------------------------------------------
function keybd:check()
	local m = redutil.read.output(string.format("pactl -- get-source-mute $(pactl get-default-source)"))
	local mute = string.match(m, ":(.*)")

	if (mute and string.find(mute, "no")) then
		keybd.microphone_slider.bar_active_color=beautiful.color.main
	else
		keybd.microphone_slider.bar_active_color=beautiful.color.main.. "40"
	end

	local v = redutil.read.output(string.format("pactl -- get-source-volume $(pactl get-default-source)"))
	local volume = string.match(v, '(%d?%d?%d)%%')
	if tonumber(volume) then
		keybd.microphone_slider:set_value(tonumber(volume))
	else
		keybd.microphone_slider:set_value(0)
	end
	-- keybd.microphone_slider:set_value(tonumber(volume))
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function keybd.new(style)

	style = style or {}
	keybd:init({})

	-- local icon = wibox.widget {
	-- 	image = gears.color.recolor_image(widget_icon_dir .. "microphone.svg", "#282c34"),
	-- 	resize = true,
	-- 	widget = wibox.widget.imagebox
	-- }
	local action_level = wibox.widget {
		-- icon,
		-- margins = { top = dpi(5), bottom = dpi(5), left = dpi(2) },
		margins = { top = dpi(15), bottom = dpi(15), left = dpi(2) },
		widget = wibox.container.margin
	}

	local slider = wibox.widget {
		nil,
		{
			id 					= 'microphone_slider',
			bar_shape           = gears.shape.rounded_rect,
			bar_height          = dpi(24),
			bar_color           = '#ffffff20',
			bar_active_color		= beautiful.color.main,
			handle_color        = beautiful.color.icon,
			handle_shape        = function(cr,w,h)
				gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
			end,
			handle_width        = dpi(24),
			handle_margins			= { top = 3, bottom = 3 },
			handle_border_color = '#00000012',
			handle_border_width = dpi(1),
			maximum				= 100,
			widget              = wibox.widget.slider,
			bar_shape						= function(cr,w,h)
				gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
			end
		},
		nil,
		expand = 'none',
		forced_height = dpi(24),
		layout = wibox.layout.align.vertical,
	}

	keybd.microphone_slider = slider.microphone_slider

	keybd.microphone_slider:connect_signal(
		'property::value',
		function()
			local microphone_slider = keybd.microphone_slider:get_value()
			local source = redutil.read.output(string.format("pactl get-default-source"))
			awful.spawn('pactl -- set-source-volume ' .. source .. ' ' ..
				microphone_slider .. '%',
				false
			)
		end
	)

	-- Update on startup
	keybd:check()

	keybd.microphone_slider:buttons(
		gears.table.join(
			awful.button(
				{},
				4,
				nil,
				function()
					if keybd.microphone_slider:get_value() > 100 then
						keybd.microphone_slider:set_value(100)
						return
					end
					keybd.microphone_slider:set_value(keybd.microphone_slider:get_value() + 5)
				end
			),
			awful.button(
				{},
				5,
				nil,
				function()
					if keybd.microphone_slider:get_value() < 0 then
						keybd.microphone_slider:set_value(0)
						return
					end
					keybd.microphone_slider:set_value(keybd.microphone_slider:get_value() - 5)
				end
			)
		)
	)

	local microphone_setting = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		{
			layout = wibox.layout.stack,
			spacing = dpi(0),
			slider,
			action_level
		}
	}

	return microphone_setting

end

-- Config metatable to call keybd module as function
-----------------------------------------------------------------------------------------------------------------------
function keybd.mt:__call(...)
	return keybd.new(...)
end

return setmetatable(keybd, keybd.mt)
