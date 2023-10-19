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
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local microphone_toggle = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon    = { redutil.base.placeholder(), redutil.base.placeholder() },
		color   = { "#a0a0a0", "#b1222b" },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.microphone_toggle") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function microphone_toggle:init(args)

	-- initialize vars
	self.style = redutil.table.merge(default_style(), args.style or {})
	self.objects = {}

end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function microphone_toggle:check()
	local m = redutil.read.output(string.format("pactl -- get-source-mute $(pactl get-default-source)"))
	local mute = string.match(m, ":(.*)")
	
	if (mute and string.find(mute, "no")) then
		self.objects[1]:set_image(self.style.icon[2])
		self.objects[1]:set_color(self.style.color[2] or style.fallback_color)
		newflat.widget.microphone.slider:check()
	else
		self.objects[1]:set_image(self.style.icon[1])
		self.objects[1]:set_color(self.style.color[1] or style.fallback_color)
		newflat.widget.microphone.slider:check()
	end
end

-- Toggle audio
-----------------------------------------------------------------------------------------------------------------------
function microphone_toggle:toggle(args)
	args = args or {}
	local microphone = args.microphone
	microphone:mute({show_notify = false})
	microphone_toggle:check()
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function microphone_toggle.new(style)

	style = style or {}
	microphone_toggle:init({})

	local widg = svgbox(style.icon or microphone_toggle.style.icon[1])
	widg:set_color(microphone_toggle.style.color[1])
	table.insert(microphone_toggle.objects, widg)

	microphone_toggle:check()
	return widg
end

-- Config metatable to call microphone_toggle module as function
-----------------------------------------------------------------------------------------------------------------------
function microphone_toggle.mt:__call(...)
	return microphone_toggle.new(...)
end

return setmetatable(microphone_toggle, microphone_toggle.mt)
