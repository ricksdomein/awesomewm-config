local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local naughty = require('naughty')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local widget_dir = gears.filesystem.get_configuration_dir() .. 'newflat/widget/dont-disturb/'
local widget_icon_dir = widget_dir .. 'icons/'

dont_disturb_state = false

local button_widget = wibox.widget {
		image = gears.color.recolor_image(widget_icon_dir .. 'notify.svg', beautiful.info_center_icon_color),
		widget = wibox.widget.imagebox,
		resize = true
}

local update_widget = function()
	if dont_disturb_state then
		button_widget:set_image(gears.color.recolor_image(widget_icon_dir .. 'dont-disturb.svg', beautiful.color.main))
	else
		button_widget:set_image(gears.color.recolor_image(widget_icon_dir .. 'notify.svg', beautiful.color.gray))
	end
end

local check_disturb_status = function()
	awful.spawn.easy_async_with_shell(
		'cat ' .. widget_dir .. 'disturb_status',
		function(stdout)
			if stdout:match('true') then
				dont_disturb_state = true
			elseif stdout:match('false') then
				dont_disturb_state = false
			else
				dont_disturb_state = false
				awful.spawn.with_shell('echo \'false\' > ' .. widget_dir .. 'disturb_status')
			end

			update_widget()
		end
	)
end

check_disturb_status()

local toggle_action = function()
	if dont_disturb_state then
		dont_disturb_state = false
	else
		dont_disturb_state = true
	end
	awful.spawn.easy_async_with_shell(
		'echo ' .. tostring(dont_disturb_state) .. ' > ' .. widget_dir .. 'disturb_status',
		function()
			update_widget()
		end
	)
end

button_widget:buttons(
	gears.table.join(
		awful.button(
			{},
			1,
			nil,
			function()
				awesome.emit_signal('widget::dont-disturb')
				toggle_action()
			end
		),
		awful.button(
			{},
			3,
			nil,
			function()
				awesome.emit_signal('widget::dont-disturb')
				toggle_action()
			end
		),
		awful.button(
			{},
			4,
			nil,
			function()
				awesome.emit_signal('widget::dont-disturb')
				toggle_action()
			end
		),
		awful.button(
			{},
			5,
			nil,
			function()
				awesome.emit_signal('widget::dont-disturb')
				toggle_action()
			end
		)
	)
)

return button_widget
