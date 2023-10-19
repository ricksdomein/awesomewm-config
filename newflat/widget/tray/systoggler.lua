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

local gears = require('gears')
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local systoggler = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon    = { redutil.base.placeholder(), redutil.base.placeholder() },
		color   = { "#b1222b" },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.systoggler") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function systoggler:init(args)

	-- initialize vars
	style = redutil.table.merge(default_style(), args.style or {})
	self.style = style
	self.objects = {}
	-- tooltip
	self.tp = tooltip({ objects = {} }, style.tooltip)

	local timer = gears.timer({ timeout = 1 })
	timer:connect_signal("timeout",
		function()
			local appcount = awesome.systray()
			if appcount == 1 then
				self.tp:set_text(appcount .." app")
			else
				self.tp:set_text(appcount .." apps")
			end
		end)
	timer:start()
	timer:emit_signal("timeout")
end

-- Toggle layout
-----------------------------------------------------------------------------------------------------------------------
function systoggler:toggle()

	if screen.primary.systray then
		if not screen.primary.systray.visible then
			for _, w in ipairs(self.objects) do
				w:set_image(systoggler.style.icon[2])
			end
		else
			for _, w in ipairs(self.objects) do
				w:set_image(systoggler.style.icon[1])
			end
		end
		screen.primary.systray.visible = not screen.primary.systray.visible
	end
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function systoggler.new(style)

	style = style or {}
	systoggler:init({})

	local widg = svgbox(systoggler.style.icon[1])
	widg:set_color(systoggler.style.color[1])
	table.insert(systoggler.objects, widg)
	systoggler.tp:add_to_object(widg)

	return widg
end

-- Config metatable to call systoggler module as function
-----------------------------------------------------------------------------------------------------------------------
function systoggler.mt:__call(...)
	return systoggler.new(...)
end

return setmetatable(systoggler, systoggler.mt)
