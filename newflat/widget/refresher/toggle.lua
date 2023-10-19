-----------------------------------------------------------------------------------------------------------------------
--                                     NewFlat refresh toggle widget                                      --
-----------------------------------------------------------------------------------------------------------------------
-- toggle widget
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
local dpi = beautiful.xresources.apply_dpi
local status_file = gears.filesystem.get_configuration_dir() .. 'newflat/widget/refresher/' .. 'status'
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local refresh = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon    = { redutil.base.placeholder() },
		color   = { "#a0a0a0", "#b1222b" },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.refresher") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function refresh:init(widget, style)

	-- initialize vars
	self.style = redutil.table.merge(default_style(), style or {})
	self.objects = {}

	refresh.timer = gears.timer({ timeout = 1, call_now = false, callback = function() refresh:update() end })


	local f = assert(io.open(status_file, "r+"))
	local t = "false"
	if f~=nil then
		t = f:read()
		io.close(f)
	end

	if t == 'true' then
		for _, w in ipairs(self.objects) do
			refresh.timer:stop()
			w:set_color(self.style.color[2] or style.fallback_color)
		end
	else
		for _, w in ipairs(self.objects) do
			refresh.timer:start()
			w:set_color(self.style.color[1] or style.fallback_color)
		end
	end
end

-- Update
-----------------------------------------------------------------------------------------------------------------------
function refresh:update()
		newflat.widget.redshift.toggle:check({})
		newflat.widget.airplane.toggle:check({})
		newflat.widget.bluetooth.toggle:check({})
		newflat.widget.audio.toggle:check()
		newflat.widget.microphone.toggle:check()
		newflat.widget.brightness.slider:update()
end

-- Toggle widget
-----------------------------------------------------------------------------------------------------------------------
function refresh:toggle()

	local f = assert(io.open(status_file, "r+"))
	local t = "false"
	if f~=nil then
		t = f:read()
		io.close(f)
	end

	if t == 'true' then
		for _, w in ipairs(self.objects) do
			refresh.timer:stop()
			w:set_color(self.style.color[1] or style.fallback_color)
			local f = assert(io.open(status_file, "w"))
			f:write("false")
			f:close()
		end
	else
		for _, w in ipairs(self.objects) do
			refresh.timer:start()
			w:set_color(self.style.color[2] or style.fallback_color)
			local f = assert(io.open(status_file, "w"))
			f:write("true")
			f:close()
		end
	end
end

-- Create a new refresher indicator widget
-----------------------------------------------------------------------------------------------------------------------
function refresh.new(style)

	style = style or {}
	refresh:init({})

	local widg = svgbox(style.icon or refresh.style.icon[1])

	widg:set_color(refresh.style.color[1])
	table.insert(refresh.objects, widg)

	--refresh:update()
	return widg
end

-- Config metatable to call refresh module as function
-----------------------------------------------------------------------------------------------------------------------
function refresh.mt:__call(...)
	return refresh.new(...)
end

return setmetatable(refresh, refresh.mt)
