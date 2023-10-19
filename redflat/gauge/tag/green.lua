-----------------------------------------------------------------------------------------------------------------------
--                                                   RedFlat tag widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget to display tag info
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local unpack = unpack or table.unpack

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local greentag = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width    = 80,
		margin   = { 2, 2, 2, 2 },
		icon     = { unknown = redutil.base.placeholder() },
		color    = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0", urgent = "#32882d" },
	}

	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.tag.green") or {})
end


-- Create a new tag widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function greentag.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		state = {},
		width = style.width or nil
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.layout.align.horizontal()
	widg._svgbox = svgbox()
	widg:set_middle(wibox.container.margin(widg._svgbox, unpack(style.margin)))
	widg:set_forced_width(data.width)
	widg:set_expand("outside")

	-- User functions
	------------------------------------------------------------
	function widg:set_state(state, s)
		data.state = state
		-- SVG Ubuntu mono bold 40 stroke 3300 ||| stroke 10.000

		local icon = style.icon[awful.layout.getname(state.layout)] or style.icon.unknown
		local icon2 = style.icon[awful.layout.getname(state.layout) .. state.text] or style.icon[awful.layout.getname(state.layout)] or style.icon.unknown
		self._svgbox:set_image(icon)
		self._svgbox:set_color(
			-- todo fix
			-- data.state.active and data.state.screen and "#98be65" or
			data.state.active and style.color.main and awful.screen.focused().index == s.index and style.color.focus or
			data.state.active and style.color.main
			or data.state.urgent and style.color.urgent
			or data.state.occupied and style.color.icon
			or style.color.gray
		)
		-- Change screen focus indicator
		screen.connect_signal("request::activate", function() self._svgbox:set_color(
					data.state.active and style.color.main and awful.screen.focused().index ~= s.index and beautiful.color.secondary or
					data.state.active and style.color.main
					or data.state.urgent and style.color.urgent
					or data.state.occupied and style.color.icon
					or style.color.gray) 



				
				end)



		-- screen.connect_signal("test::test",
		-- 	function()
		-- 		self._svgbox:set_image(icon2)
		-- 	end
		-- 	)
		-- 	screen.connect_signal("test::test2",
		-- 		function()
		-- 			self._svgbox:set_image(icon)
		-- 		end
		-- 		)
				-- awful.keygrabber {
				--     keybindings = {
				--         {{         }, 'Super_L', function() screen.emit_signal("test::test") end},
				--     },
				--     -- Note that it is using the key name and not the modifier name.
				--     stop_key           = 'Mod4',
				--     stop_event         = 'release',
				--     start_callback     = function() screen.emit_signal("test::test2") end,
				--     stop_callback      = function() screen.emit_signal("test::test2") end,
				--     export_keybindings = true,
				-- }

		-- key.connect_signal("press", function(k)
    -- self._svgbox:set_image(icon2)
		-- end)
		-- key.connect_signal("release", function(k)
		-- self._svgbox:set_image(icon)
		-- end)
	end


	function widg:set_width(width)
		data.width = width
		self.set_forced_width(width)
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call greentag module as function
-----------------------------------------------------------------------------------------------------------------------
function greentag.mt:__call(...)
	return greentag.new(...)
end

return setmetatable(greentag, greentag.mt)
