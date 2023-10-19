-----------------------------------------------------------------------------------------------------------------------
--                                                Rules config                                                       --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful =require("awful")
local beautiful = require("beautiful")
local redtitle = require("redflat.titlebar")

-- Initialize tables and vars for the module
-----------------------------------------------------------------------------------------------------------------------
local rules = {}

rules.base_properties = {
	border_width     = beautiful.border_width,
	border_color     = beautiful.border_normal,
	focus            = awful.client.focus.filter,
	raise            = true,
	size_hints_honor = false,
	screen           = awful.screen.preferred,
	titlebars_enabled = true,
}

rules.floating_any = {
	class = {
		"Clipflap", "Run.py", "gnome-calculator", "gcolor3", "org.gnome.clocks",
	},
	role = { "AlarmWindow", "pop-up", },
	type = { "dialog" },
}

rules.titlebar_exceptions = {
	class = { "Cavalcade", "Clipflap", "Steam", "Qemu-system-x86_64" }
}

rules.maximized = {
	class = { "Emacs24" }
}

-- Build rule table
-----------------------------------------------------------------------------------------------------------------------
function rules:init(args)

	args = args or {}
	self.base_properties.keys = args.hotkeys.keys.client
	self.base_properties.buttons = args.hotkeys.mouse.client
	self.env = args.env or {}


	-- Build rules
	--------------------------------------------------------------------------------
	self.rules = {
		{
			rule       = {},
			properties = args.base_properties or self.base_properties
		},
		{
			rule_any   = args.floating_any or self.floating_any,
			properties = { floating = true }
		},
		{
			rule_any   = self.maximized,
			callback = function(c)
				c.maximized = true
				redtitle.cut_all({ c })
				c.height = c.screen.workarea.height - 2 * c.border_width
			end
		},
		{
			rule_any   = { type = { "normal", "dialog" }},
			except_any = self.titlebar_exceptions,
			properties = { titlebars_enabled = true }
		},
		{
			rule_any   = { type = { "normal" }},
			-- properties = { placement = awful.placement.no_overlap + awful.placement.no_offscreen }
			properties = { placement = awful.placement.no_offscreen }
		},

		-- Tags placement
		{
			rule = { instance = "Xephyr" },
			properties = { tag = self.env.theme == "ruby" and "Test" or "Free", fullscreen = true }
		},

		-- Jetbrains splash screen fix
		{
			rule_any = { class = { "jetbrains-%w+", "java-lang-Thread" } },
			callback = function(jetbrains)
				if jetbrains.skip_taskbar then jetbrains.floating = true end
			end
		},
		{
			rule_any = { class = { "albert", "Tint2" } },
			except_any = self.titlebar_exceptions,
			properties = { titlebars_enabled = false, border_width = 0 }
		},
		{
			rule_any = { class = { "Plank" } },
			except_any = self.titlebar_exceptions,
			properties = { titlebars_enabled = false, border_width = 0, ontop = true }
		},
		{
			rule_any   = { class = { "drawterminal" } },
			except_any = self.titlebar_exceptions,
			properties = { floating = true }
		},
		{
			rule_any   = { class = { "terminal-floating" } },
			except_any = self.titlebar_exceptions,
			properties = { placement = awful.placement.centered, floating = true }
		},
		{
			rule_any   = { class = { "Zenity" } },
			properties = { skip_taskbar = true, ontop = true }
		},
		-- Hide trayer from taskbar
		-- {
		-- 	 rule_any = { class = { "Swallow" } },
		--   properties = { skip_taskbar = true }
		-- },
	}


	-- Set rules
	--------------------------------------------------------------------------------
	awful.rules.rules = rules.rules
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return rules
