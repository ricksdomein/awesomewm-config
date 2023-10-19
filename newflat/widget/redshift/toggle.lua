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
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local audio_toggle = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon    = { redutil.base.placeholder(), redutil.base.placeholder() },
		color   = { "#a0a0a0", "#a0a0a0", "#b1222b" },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.redshift") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:init(args)

	-- initialize vars
	self.style = redutil.table.merge(default_style(), args.style or {})
	self.objects = {}
	self.blue_light_state = "OFF"


end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:update()
	if self.blue_light_state == "ON" then
		for _, w in ipairs(self.objects) do
			w:set_image(self.style.icon[3])
			w:set_color(self.style.color[3] or style.fallback_color)
		end
	elseif self.blue_light_state == "AUTO" then
		for _, w in ipairs(self.objects) do
			w:set_image(self.style.icon[2])
			w:set_color(self.style.color[3] or style.fallback_color)
		end
	else
		for _, w in ipairs(self.objects) do
			w:set_image(self.style.icon[1])
			w:set_color(self.style.color[2] or style.fallback_color)
		end
	end
end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:check()
	awful.spawn.easy_async_with_shell(
		[[
		if pgrep -fx 'redshift -l 0 0 -t 4500 4500 -r'
		then
			echo 'ON'
		elif pgrep -fx 'redshift -c ]] .. awful.util.get_configuration_dir() .. [[newflat/widget/redshift/redshift.conf'
		then
			echo 'AUTO'
		else
			pkill redshift
		    echo 'OFF'
		fi
		]],
		function(stdout)
			if stdout:match('ON') then
				self.blue_light_state = "ON"
			elseif stdout:match('AUTO') then
				self.blue_light_state = "AUTO"
			else
				self.blue_light_state = "OFF"
			end
			audio_toggle:update()
		end
	)
end

-- Toggle audio
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:toggle(args)
	if args.reverse then
		awful.spawn.easy_async_with_shell(
			[[
			if pgrep -fx 'redshift -l 0 0 -t 4500 4500 -r'
			then
				pkill redshift
				redshift -c ]] .. awful.util.get_configuration_dir() .. [[newflat/widget/redshift/redshift.conf &>/dev/null &
				echo 'AUTO'

			elif pgrep -fx 'redshift -c ]] .. awful.util.get_configuration_dir() .. [[newflat/widget/redshift/redshift.conf'
			then
				pkill redshift
				echo 'OFF'
			else
			        pkill redshift
			        redshift -l 0:0 -t 4500:4500 -r &>/dev/null &
			        echo 'ON'
			fi
			]],
			function(stdout)
				if stdout:match('ON') then
					self.blue_light_state = "ON"
				elseif stdout:match('AUTO') then
					self.blue_light_state = "AUTO"
				else
					self.blue_light_state = "OFF"
				end
				audio_toggle:update()
			end
		)
	else
		awful.spawn.easy_async_with_shell(
			[[
			if pgrep -fx 'redshift -l 0 0 -t 4500 4500 -r'
			then
				pkill redshift
				echo 'OFF'
			elif pgrep -fx 'redshift -c ]] .. awful.util.get_configuration_dir() .. [[newflat/widget/redshift/redshift.conf'
			then
				pkill redshift
				redshift -l 0:0 -t 4500:4500 -r &>/dev/null &
				echo 'ON'
			else
				pkill redshift
				redshift -c ]] .. awful.util.get_configuration_dir() .. [[newflat/widget/redshift/redshift.conf &>/dev/null &
				echo 'AUTO'
			fi
			]],
			function(stdout)
				if stdout:match('ON') then
					self.blue_light_state = "ON"
				elseif stdout:match('AUTO') then
					self.blue_light_state = "AUTO"
				else
					self.blue_light_state = "OFF"
				end
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
