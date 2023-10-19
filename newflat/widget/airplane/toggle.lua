-----------------------------------------------------------------------------------------------------------------------
--                                     NewFlat audio toggle widget                                      --
-----------------------------------------------------------------------------------------------------------------------
-- toggle audio
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local awful = require("awful")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

local newflat = require("newflat")

local gears = require('gears')
local widget_icon_dir = gears.filesystem.get_configuration_dir() .. 'newflat/widget/airplane/icons/'
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local audio_toggle = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon    = { redutil.base.placeholder(), redutil.base.placeholder() },
		color   = { "#a0a0a0", "#b1222b" },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.airplane") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:init(args)

	-- initialize vars
	self.style = redutil.table.merge(default_style(), args.style or {})
	self.objects = {}
	self.device_state = false

end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:update()
	if self.device_state then
		for _, w in ipairs(self.objects) do
			w:set_image(self.style.icon[2])
			w:set_color(self.style.color[2] or style.fallback_color)
		end
	else
		for _, w in ipairs(self.objects) do
			w:set_image(self.style.icon[1])
			w:set_color(self.style.color[1] or style.fallback_color)
		end
	end
end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:check()
	awful.spawn.easy_async_with_shell(
		'rfkill list wlan',
		function(stdout)
			if stdout:match('Soft blocked: yes') then
				self.device_state = true
			else
				self.device_state = false
			end
			audio_toggle:update()
		end
	)
end

-- Toggle audio
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:toggle()
	if self.device_state then
		awful.spawn.easy_async_with_shell(
		[[

			rfkill unblock wlan

			# Create an AwesomeWM Notification
			awesome-client "
			naughty = require('naughty')
			naughty.notification({
				app_name = 'Network Manager',
				title = '<b>Airplane mode disabled!</b>',
				message = 'Initializing network devices',
				icon = ']] .. widget_icon_dir .. 'airplane-mode-off' .. '.svg' .. [['
			})
			"
		]],
			function(stdout)
				self.device_state = false
				audio_toggle:update()
			end
		)
	else
		awful.spawn.easy_async_with_shell(
		[[

			rfkill block wlan

			# Create an AwesomeWM Notification
			awesome-client "
			naughty = require('naughty')
			naughty.notification({
				app_name = 'Network Manager',
				title = '<b>Airplane mode enabled!</b>',
				message = 'Disabling radio devices',
				icon = ']] .. widget_icon_dir .. 'airplane-mode' .. '.svg' .. [['
			})
			"
		]],
			function(stdout)
				self.device_state = true
				audio_toggle:update()
			end
		)
	end
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle.new(style)

	style = style or {}
	audio_toggle:init({})

	local widg = svgbox(style.icon or audio_toggle.style.icon[1])
	widg:set_color(audio_toggle.style.color[1])
	table.insert(audio_toggle.objects, widg)

	audio_toggle:check()
	return widg
end

-- Config metatable to call audio_toggle module as function
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle.mt:__call(...)
	return audio_toggle.new(...)
end

return setmetatable(audio_toggle, audio_toggle.mt)
