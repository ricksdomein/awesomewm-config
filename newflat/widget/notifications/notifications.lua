local gears = require('gears')
local wibox = require('wibox')
local awful = require('awful')
local ruled = require('ruled')
local naughty = require('naughty')
local menubar = require('menubar')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

-- Defaults
naughty.config.defaults.ontop = true
naughty.persistence_enabled  = true
naughty.config.defaults.icon_size = dpi(32)
-- naughty.config.defaults.timeout = 6
naughty.config.defaults.title = 'System Notification'
naughty.config.defaults.margin = dpi(16)
--naughty.config.defaults.border_width = 0
naughty.config.defaults.position = 'top_left'
-- naughty.config.defaults.shape =  function(cr, w, h)
-- 				gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
-- 			end
naughty.config.defaults.shape =   function(cr, w, h)
	gears.shape.rectangle(cr, w, h)
end

-- Apply theme variables
naughty.config.padding = dpi(8)
naughty.config.spacing = dpi(8)
naughty.config.icon_dirs = {
	'/usr/share/icons/Tela',
	'/usr/share/icons/Tela-blue-dark',
	'/usr/share/icons/Papirus/',
	'/usr/share/icons/Papirus-Dark/',
	'/usr/share/icons/la-capitaine-icon-theme/',
	'/usr/share/icons/gnome/',
	'/usr/share/icons/hicolor/',
	'/usr/share/pixmaps/'
}
naughty.config.icon_formats = { 'svg', 'png', 'jpg', 'gif' }





-- Presets / rules

ruled.notification.connect_signal(
	'request::rules',
	function()

		-- Critical notifs
		ruled.notification.append_rule {
			rule       = { urgency = 'critical' },
			properties = {
				font        		= 'Inter Bold 10',
				bg 					= '#ff0000',
				fg 					= '#ffffff',
				margin 				= dpi(16),
				position 			= 'top_left',
				implicit_timeout	= beautiful.notification.timeout.critical
			}
		}

		-- Normal notifs
		ruled.notification.append_rule {
			rule       = { urgency = 'normal' },
			properties = {
				font        		= 'Inter Regular 10',
				bg      			= beautiful.transparent,
				fg 					= beautiful.fg_normal,
				margin 				= dpi(16),
				position 			= 'top_left',
				implicit_timeout 	= beautiful.notification.timeout.normal
			}
		}

		-- Low notifs
		ruled.notification.append_rule {
			rule       = { urgency = 'low' },
			properties = {
				font        		= 'Inter Regular 10',
				bg     				= beautiful.transparent,
				fg 					= beautiful.fg_normal,
				margin 				= dpi(16),
				position 			= 'top_left',
				implicit_timeout	= beautiful.notification.timeout.low,

			}
		}
	end
	)

-- Error handling
naughty.connect_signal(
	'request::display_error',
	function(message, startup)
		naughty.notification {
			urgency = 'critical',
			title   = 'Oops, an error happened'..(startup and ' during startup!' or '!'),
			message = message,
			app_name = 'System Notification',
			icon = beautiful.awesome_icon
		}
	end
)

-- XDG icon lookup
naughty.connect_signal(
	'request::icon',
	function(n, context, hints)
		if context ~= 'app_icon' then return end

		local path = menubar.utils.lookup_icon(hints.app_icon) or
		menubar.utils.lookup_icon(hints.app_icon:lower())

		if path then
			n.icon = path
		end
	end
)
naughty.connect_signal(
	'request::display',
	function(n)
		if not dont_disturb_state then
			awful.spawn.with_shell('canberra-gtk-play -i message')
		end
	end
)
local redflat = require("redflat")
-- Connect to naughty on display signal
naughty.connect_signal(
	'request::display',
	function(n)

		-- Actions Blueprint
		local actions_template = wibox.widget {
			notification = n,
			base_layout = wibox.widget {
				spacing        = dpi(0),
				layout         = wibox.layout.flex.horizontal
			},
			widget_template = {
				{
					{
						{
							{
								id     = 'text_role',
								font   = 'Inter Regular 10',
								widget = wibox.widget.textbox
							},
							widget = wibox.container.place
						},
					},
					bg                 = beautiful.groups_bg,
					forced_height      = dpi(30),
					widget             = wibox.container.background,
					shape = function(cr, w, h)
						gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
					end,
				},
				margins = dpi(4),
				widget  = wibox.container.margin
			},
			style = { underline_normal = false, underline_selected = true },
			widget = naughty.list.actions,

		}



		local bla123 = wibox.widget{
			markup = 1.0, -- n.timeout
			-- align  = 'center',
			-- valign = 'center',
			widget = wibox.widget.textbox
		}

		-- Notifbox Blueprint
		local notification_popup = naughty.layout.box({
			notification = n,
			cursor = "hand2",
			type = 'notification',
			screen = awful.screen.preferred(),
			-- shape = function(cr, w, h)
			-- 	gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
			-- end,
			shape = function(cr, w, h)
				gears.shape.rectangle(cr, w, h)
			end,
			widget_template = {
				{
					{
						{
							{
								{
									{
										{
											{
												{
													-- { margins = 0, widget = redflat.gauge.monitor.circle},
													-- {
													-- 	layout = wibox.layout.align.vertical,
													-- 	expand = 'none',
													-- 	nil,
														-- {
														-- 	{
														-- 		markup = n.app_name or 'System Notification',
														-- 		font = 'Inter Bold 10',
														-- 		align = 'center',
														-- 		valign = 'center',
														-- 		widget = wibox.widget.textbox
														-- 	},
														-- 	{
														-- 	{
														-- 		align = 'right',
														-- 		widget = redflat.gauge.monitor.circle,
														-- 	},
														-- 	margins = dpi(0),
														-- 	widget  = wibox.container.margin,
														-- 	},
														-- 	layout = wibox.layout.fixed.horizontal
														-- },
													-- 	nil
													-- },
													-- {
													-- 	markup = n.app_name or 'System Notification',
													-- 	font = 'Inter Bold 10',
													-- 	align = 'center',
													-- 	valign = 'center',
													-- 	widget = wibox.widget.textbox

													-- },
													{
														{
															{
															
																{

																	{
																		nil,
																		{
																			
																				
																			markup = n.app_name or 'System Notification',
																			font = 'Inter Bold 10',
																			-- align = 'center',
																			-- valign = 'center',
																			align = 'center',
																			widget = wibox.widget.textbox
																		
																			
																		},

														
																		{
																			align = 'right',
																			widget = bla123,
																		},
																		layout = wibox.layout.align.horizontal,
																	},
																	layout = wibox.layout.fixed.vertical,
																},
																layout = wibox.layout.align.vertical,
																expand = 'none',
															},
															margins = beautiful.notification_margin,
															widget  = wibox.container.margin,
														},
													
														margins = beautiful.notification_margin,
														widget  = wibox.container.margin,
													},
																			
													margins = beautiful.notification_margin,
													widget  = wibox.container.margin,

												},
												bg = beautiful.background,
												widget  = wibox.container.background,
												
											},
											{
												{
													{
														resize_strategy = 'center',
														widget = naughty.widget.icon,
													},
													margins = beautiful.notification_margin,
													widget  = wibox.container.margin,
												},
												{
													{
														layout = wibox.layout.align.vertical,
														expand = 'none',
														nil,
														{
															{
																align = 'left',
																widget = naughty.widget.title
															},
															{
																align = 'left',
																widget = naughty.widget.message,
															},
															layout = wibox.layout.fixed.vertical
														},
														nil
													},
													margins = beautiful.notification_margin,
													widget  = wibox.container.margin,
												},
												layout = wibox.layout.fixed.horizontal,
											},
											fill_space = true,
											spacing = beautiful.notification_margin,
											layout  = wibox.layout.fixed.vertical,
										},
										-- Margin between the fake background
										-- Set to 0 to preserve the 'titlebar' effect
										margins = dpi(0),
										widget  = wibox.container.margin,
									},
									bg = beautiful.transparent,
									widget  = wibox.container.background,
								},
								-- Actions
								actions_template,
								spacing = dpi(4),
								layout  = wibox.layout.fixed.vertical,
							},
							bg     = beautiful.transparent,
							id     = 'background_role',
							widget = naughty.container.background,
						},
						strategy = 'min',
						width    = dpi(250),
						widget   = wibox.container.constraint,
					},
					strategy = 'max',
					height    = dpi(250),
					width    = dpi(250),
					widget   = wibox.container.constraint

				},
				bg = beautiful.background,
				-- shape = function(cr, w, h)
				-- 	gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
				-- end,
				shape = function(cr, w, h)
					gears.shape.rectangle(cr, w, h)
				end,
				widget = wibox.container.background
			}
		})


		local bla_timeout = n.timeout
		local bla = gears.timer({ 
			timeout = 0.1,
			call_now = false,
			autostart = true,
			single_shot = false,
			callback = function() 
				-- awful.spawn([[notify-send test]])
				-- n:destroy()
				bla_timeout = bla_timeout - 0.1
				bla123.markup = bla_timeout
				
			end 
		})
		-- timer = gears.timer {
		-- 	timeout   = 1
		-- }
		
		-- timer:connect_signal("timeout", function()
		-- 	awful.spawn([[notify-send test]])
		-- 	end
		-- )
		
		-- timer:start()

		-- bla:connect_signal("ended", function()
		-- 	n:destroy()
		-- end)
	

		notification_popup:connect_signal("mouse::enter", function()
			--- Absurdly big number because setting it to 0 doesn't work
			n:set_timeout(4294967)
			bla:stop()
			-- awful.easy_async_with_shell([[notify-send test]])
		end)

		notification_popup:connect_signal("mouse::leave", function()
			-- n:set_timeout(naughty.config.defaults.timeout)
			n:set_timeout(bla_timeout)
			-- awful.spawn([[notify-send ]] .. bla_timeout)
			bla:start()
		end)
		-- bla:start()

		-- Destroy popups if dont_disturb_state mode is on
		-- Or if the info_center is visible
		local focused = awful.screen.focused()
		if _G.dont_disturb_state or (focused.info_center and focused.info_center.visible) then
			naughty.destroy_all_notifications(nil, 1)
		end
	end
)