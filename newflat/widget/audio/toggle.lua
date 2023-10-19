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
local audio_toggle = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon    = { redutil.base.placeholder(), redutil.base.placeholder() },
		color   = { "#a0a0a0", "#b1222b" },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.audio_toggle") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:init(args)

	-- initialize vars
	self.style = redutil.table.merge(default_style(), args.style or {})
	self.objects = {}

end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:check()
	local m = redutil.read.output(string.format("pactl -- get-sink-mute $(pactl get-default-sink)"))
	local mute = string.match(m, ":(.*)")

	if (mute and string.find(mute, "no")) then
		self.objects[1]:set_image(self.style.icon[2])
		self.objects[1]:set_color(self.style.color[2] or style.fallback_color)
		newflat.widget.audio.slider:toggle()
	else
		self.objects[1]:set_image(self.style.icon[1])
		self.objects[1]:set_color(self.style.color[1] or style.fallback_color)
		newflat.widget.audio.slider:toggle()
	end
end

-- Toggle audio
-----------------------------------------------------------------------------------------------------------------------
function audio_toggle:toggle(args)
	args = args or {}
	local audio = args.audio
	audio:mute({show_notify = false})
	audio_toggle:check()
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
