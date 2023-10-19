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
local widget_icon_dir = gears.filesystem.get_configuration_dir() .. 'newflat/widget/brightness/icons/'
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


local function default_style2()
	local style = {
		step = 5,
		get = 'brightnessctl g',
		set = 'brightnessctl s',
		-- up = 'brightnessctl s '.. step ..'%-',
		-- down = 'brightnessctl s +'.. step ..'%',
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.backlight") or {})
end
-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function keybd:init(style)

	-- initialize vars
	style = redutil.table.merge(default_style(), style or {})
	style = redutil.table.merge(default_style2(), style or {})
	self.style = style

end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function keybd:update()

	awful.spawn.easy_async_with_shell(
		keybd.style.get,
		-- 'cat /sys/class/backlight/*backlight/bri*',
		function(stdout)
			local brightness = string.match(stdout, '(%d+)')
			keybd.brightness_slider:set_value(tonumber(brightness))
		end
	)
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function keybd.new(style)

	style = style or {}
	keybd:init({})

	-- local icon = wibox.widget {
	-- 	image = gears.color.recolor_image(widget_icon_dir .. "brightness.svg", "#282c34"),
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
			id 					= 'brightness_slider',
			bar_shape           = gears.shape.rounded_rect,
			bar_height          = dpi(24),
			bar_color           = '#ffffff20',
			bar_active_color	= beautiful.color.main,
			handle_color        = beautiful.color.icon,
			handle_shape        = function(cr,w,h)
				gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
			end,
			handle_width        = dpi(24),
			handle_margins		= { top = 3, bottom = 3 },
			handle_border_color = '#00000012',
			handle_border_width = dpi(1),
			maximum				= 19393,
			minimum				= 1,
			widget              = wibox.widget.slider,
			bar_shape			= function(cr,w,h)
				gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 6)
			end
		},
		nil,
		expand = 'none',
		forced_height = dpi(24),
		layout = wibox.layout.align.vertical
	}

	keybd.brightness_slider = slider.brightness_slider

	keybd.brightness_slider:connect_signal(
		'property::value',
		function()
			local brightness_level = keybd.brightness_slider:get_value()
			-- awful.spawn('echo ' .. math.max(brightness_level, 1) .. ' > /sys/class/backlight/*backlight/bri*',
			-- awful.spawn.with_shell('canberra-gtk-play -i audio-volume-change')
			awful.spawn(keybd.style.set .. ' ' .. math.max(brightness_level, 1),
				false
			)
		end
	)

	keybd:update(style)

	keybd.brightness_slider:buttons(
		gears.table.join(
			awful.button(
				{},
				4,
				nil,
				function()
					if keybd.brightness_slider:get_value() > keybd.brightness_slider.maximum then
						keybd.brightness_slider:set_value(keybd.brightness_slider.maximum)
						return
					end
					-- awful.spawn.with_shell("notify-send " .. keybd.style.get)
					local step = keybd.brightness_slider.maximum * (keybd.style.step/100)
					keybd.brightness_slider:set_value(keybd.brightness_slider:get_value() + step)
				end
			),
			awful.button(
				{},
				5,
				nil,
				function()
					if keybd.brightness_slider:get_value() < keybd.brightness_slider.minimum then
						keybd.brightness_slider:set_value(keybd.brightness_slider.minimum)
						return
					end
					local step = keybd.brightness_slider.maximum * (keybd.style.step/100)
					keybd.brightness_slider:set_value(keybd.brightness_slider:get_value() - step)
				end
			)
		)
	)

	local brightness_setting = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		{
			layout = wibox.layout.stack,
			spacing = dpi(0),
			slider,
			action_level
		}
	}

	return brightness_setting

end

-- Config metatable to call keybd module as function
-----------------------------------------------------------------------------------------------------------------------
function keybd.mt:__call(...)
	return keybd.new(...)
end

return setmetatable(keybd, keybd.mt)
