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
local notifications_toggle = { mt = {} }
dont_disturb_state = false
-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon    = { redutil.base.placeholder(), redutil.base.placeholder() },
		color   = { "#a0a0a0", "#b1222b" },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.notifications_toggle") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function notifications_toggle:init(args)

	-- initialize vars
	self.style = redutil.table.merge(default_style(), args.style or {})
	self.objects = {}

end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function notifications_toggle:check()

	if not dont_disturb_state then
		self.objects[1]:set_image(self.style.icon[2])
		self.objects[1]:set_color(self.style.color[2] or style.fallback_color)
		awesome.emit_signal('widget::dont-disturb')
	else
		self.objects[1]:set_image(self.style.icon[1])
		self.objects[1]:set_color(self.style.color[1] or style.fallback_color)
		awesome.emit_signal('widget::dont-disturb')
	end
end

-- Toggle audio
-----------------------------------------------------------------------------------------------------------------------
function notifications_toggle:status()
	return dont_disturb_state
end

-- Toggle audio
-----------------------------------------------------------------------------------------------------------------------
function notifications_toggle:toggle(args)
	args = args or {}
	-- local audio = args.audio
	-- audio:mute({show_notify = false})
	if dont_disturb_state then
		dont_disturb_state = false
	else
		dont_disturb_state = true
	end
	notifications_toggle:check()
	
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function notifications_toggle.new(style)

	style = style or {}
	notifications_toggle:init({})

	local widg = svgbox(style.icon or notifications_toggle.style.icon[1])
	widg:set_color(notifications_toggle.style.color[1])
	table.insert(notifications_toggle.objects, widg)

	notifications_toggle:check()
	awesome.emit_signal('widget::dont-disturb')
	return widg
end

-- Config metatable to call notifications_toggle module as function
-----------------------------------------------------------------------------------------------------------------------
function notifications_toggle.mt:__call(...)
	return notifications_toggle.new(...)
end

return setmetatable(notifications_toggle, notifications_toggle.mt)
