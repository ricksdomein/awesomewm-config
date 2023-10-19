-----------------------------------------------------------------------------------------------------------------------
--                                           RedFlat indicator widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Image indicator
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string

local beautiful = require("beautiful")
local wibox = require("wibox")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

local naughty = require("naughty")
-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local gicon = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon        = { full = redutil.base.placeholder(), unknown = redutil.base.placeholder(), charged = redutil.base.placeholder(), charging = redutil.base.placeholder(), discharging = redutil.base.placeholder()},
		-- icon        = redutil.base.placeholder(),
		step        = 0.05,
		is_vertical = false,
		color       = { main = "#b1222b", icon = "#a0a0a0", urgent = "#32882d" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.icon.battery") or {})
	-- return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.icon.single") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function pattern_string_v(height, value, c1, c2)
	-- return string.format("linear:0,%s:0,0:0,%s:%s,%s:%s,%s:1,%s", height, c1, value, c1, value, c2, c2)
	return {
		type = "linear",
		from = { 0,height },
		to = { 0,0 },
		stops = { { 0, c1 }, { value, c1 }, { value, c2 }, { 1, c2 } }
	  }
end

local function pattern_string_h(width, value, c1, c2)
	return string.format("linear:0,0:%s,0:0,%s:%s,%s:%s,%s:1,%s", width, c1, value, c1, value, c2, c2)
end

-- Create a new gicon widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function gicon.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})
	local pattern = style.is_vertical and pattern_string_v or pattern_string_h

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = wibox.container.background(svgbox(style.icon.full))
	widg._data = {
		color = style.color.main,
		level = 0,
	}

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x, force_redraw)

		if x.value > 1 then x.value = 1 end



		-- ["Full\n"]        = "↯",
		-- ["Unknown\n"]     = "⌁",
		-- ["Charged\n"]     = "↯",
		-- ["Charging\n"]    = "+",
		-- ["Discharging\n"] = "-"



		if x.status == "↯" then 
			self.widget:set_image(style.icon.full)
		elseif x.status == "⌁" then
			self.widget:set_image(style.icon.unknown)
		elseif x.status == "↯" then
			self.widget:set_image(style.icon.charged)
		elseif x.status == "+" then
			self.widget:set_image(style.icon.charging)
		elseif x.status == "-" then
			self.widget:set_image(style.icon.Discharging)
		else
			self.widget:set_image(style.icon.unknown)
		end




		if self.widget._image then
			local level = math.floor(x.value / style.step) * style.step

			if force_redraw or level ~= self._data.level then
				
				self._data.level = level
				local d = style.is_vertical and self.widget._image.height or self._image.width
		
				self.widget:set_color(pattern(d, level, self._data.color, style.color.icon))
				
			end
		end
	end

	function widg:set_alert(alert)


		local old_color = self._data.color
		self._data.color = alert and style.color.urgent or style.color.main
		if self._data.color ~= old_color then
			-- force redraw if color has changed
			self:set_value(self._data.level, true)
			
			if not self._data.notify then
				naughty.notify({title="Low Battery",text=(self._data.level * 100) .. "% battery remaining.", urgency="critical" })
				self._data.notify=1
			end
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call gicon module as function
-----------------------------------------------------------------------------------------------------------------------
function gicon.mt:__call(...)
	return gicon.new(...)
end

return setmetatable(gicon, gicon.mt)
