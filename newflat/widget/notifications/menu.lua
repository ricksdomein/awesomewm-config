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
-- local redmenu = require("redflat.menu")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

local naughty = require("naughty")

local separator = require("redflat.gauge.separator")
local newflatmenu = require("newflat.widget.menu")
local wibox = require("wibox")

local newflat = require("newflat")

local notifbox_box = require('newflat.widget.notifications.notifbox.build-notifbox.notifbox-builder')
local gears = require('gears')
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'newflat/widget/notifications/notifbox/icons/'

local widget_dir = config_dir .. 'newflat/widget/notifications/'
local disturb_widget_icon_dir = widget_dir .. 'icons/'
-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local notifications = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon           = redutil.base.placeholder(),
		micon          = { blank = redutil.base.placeholder({ txt = " " }),
						 close = redutil.base.placeholder({ txt = "x" }) },
		menu           = { color = { right_icon = "#a0a0a0" } },
		layout_color   = { "#a0a0a0", "#b1222b", "#ff0000" },
		fallback_color = "#32882d",
		titleline            = { font = "Sans 16 bold", height = 35 },
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.notifications") or {})
end

function notifications:clean(style)
	local classbox = wibox.widget.textbox()
	classbox:set_text("Notification List")
	classbox:set_font(style.titleline.font)
	classbox:set_align ("center")

	local classline = wibox.container.constraint(classbox, "exact", nil, style.titleline.height)
	local menusep = { widget = separator.horizontal(style.separator) }

	local notifbox_layout = wibox.container.constraint(nil, "exact", nil, 115)

	menu_items2 = {
		-- { widget = stateline, focus = true },
		{ widget = classline },
		menusep,
		{ widget = notifbox_layout},
		menusep,
		{ "Close", function()  notifications:toggle_menu() end, nil, style.micon.close }
	}
	return menu_items2
end

function notifications:popup(style)





end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function notifications:init(style)

	-- initialize vars
	style = redutil.table.merge(default_style(), style or {})
	self.style = style
	self.objects = {}

	-- tooltip
	self.tp = tooltip({ objects = {} }, style.tooltip)

	-- notifications:popup(style)





	-- local notifbox_core = require('newflat.widget.notif-center.build-notifbox')
	-- local reset_notifbox_layout = notifbox_core.reset_notifbox_layout
	--
	-- local notifbox_layout = wibox.widget {
	-- 	widget   = wibox.container.constraint,
	-- 	notifbox_core.notifbox_layout,
	-- }
	-- local notifbox_layout = wibox.container.constraint(notifbox_layout, "exact", nil, 300)


	-- local stateline_horizontal = wibox.layout.flex.horizontal()
	-- local stateline_vertical = wibox.layout.align.vertical()
	-- stateline_vertical:set_second(stateline_horizontal)
	-- stateline_vertical:set_expand("outside")
	-- local stateline = wibox.container.constraint(stateline_vertical, "exact", nil, style.titleline.height)
	-- local l = wibox.layout.align.horizontal()
	-- l:set_expand("outside")
	-- l:set_second(require('newflat.widget.dont-disturb'))
	-- stateline_horizontal:add(l)




	notifications:counter(0)
	clean_empty=1

	menu_items2 = notifications:clean(style)
	self.menu = newflatmenu({ hide_timeout = 1, theme = style.menu, items = menu_items2 })


	-- Create menu
	------------------------------------------------------------
	-- self.menu = redmenu({
	-- 	theme = style.menu,
	-- 	items = menu_items2,
	-- })


	-- initialize menu
	-- self.menu = redmenu({ hide_timeout = 1, theme = style.menu, items = menu_items2 })
	-- if self.menu.items[1].right_icon then
	-- 	self.menu.items[1].right_icon:set_image(style.micon.check)
	-- end


	self.notification_count = 0


	-- update layout data
	self.update = function()


		-- update tooltip
		--keybd.tp:set_text("0 Notifications")

		-- update menu
		-- for i = 1, #self.layouts do
		-- 	local mark = layout == i and style.micon.check or style.micon.blank
		-- 	keybd.menu.items[i].right_icon:set_image(mark)
		-- end
		-- local notifbox_add = function(n, notif_icon, notifbox_color)

			-- local bla = wibox.widget.textbox()
			-- bla:set_markup("<b>"..n.title.."</b> " .. n.message)
			-- bla:set_font(style.titleline.font)

			-- local test = wibox.widget {
			-- 	strategy = 'max',
			-- 	height   = 500,
			-- 	widget   = wibox.container.constraint,
			-- 	--s.notifbox_layout,
			-- }
			--
			--
			-- local test = wibox.widget {
			--
			--         {
			--             text = n.app_name,
			-- 						font = style.titleline.font,
			--             widget = wibox.widget.textbox,
			--         },
			--         {
			--             text = n.title,
			--             widget = wibox.widget.textbox,
			--         },
			-- 				{
			-- 						text = n.message,
			-- 						widget = wibox.widget.textbox,
			-- 				},
			--         layout = wibox.layout.fixed.vertical,
			-- 	}
			--
			--
			-- local bla = wibox.container.constraint(test, "max", nil, 500)
			-- table.insert(menu_items2, 3, { widget = bla})
			-- self.menu = redmenu({ hide_timeout = 1, theme = style.menu, items = menu_items2 })

			-- update tooltip
			-- keybd:counter(self.notification_count + 1)

			--keybd.tp:set_text(n.title)
			-- notif_core.notifbox_layout:insert(
			-- 	1,
			-- 	notifbox_box(
			-- 		n,
			-- 		notif_icon,
			-- 		n.title,
			-- 		n.message,
			-- 		n.app_name,
			-- 		notifbox_color
			-- 	)
			-- )
		-- end
		local notifbox_add_expired = function(n, notif_icon, notifbox_color)
			n:connect_signal(
				'destroyed',
				function(self2, reason, keep_visble)

					if reason == 1 then
						if not self.menu.wibox.visible then
							for _, w in ipairs(self.objects) do
								--w:set_image(self.style.icon[2])
								w:set_color(notifications.style.layout_color[3] or style.fallback_color)
							end
						end
						notifications:counter(self.notification_count + 1)

						local notifbox_color = beautiful.transparent
						if n.urgency == 'critical' then
							-- notifbox_color = n.bg .. '66'
							notifbox_color = notifications.style.layout_color[3]
						end

						local notif_icon = n.icon or n.app_icon
						if not notif_icon then
							notif_icon = widget_icon_dir .. 'new-notif' .. '.svg'
						end

						local notifbox_layout = wibox.container.constraint(notifbox_box(
							n,
							notif_icon,
							n.title,
							n.message,
							n.app_name,
							notifbox_color
						), "exact", nil, 115)
						table.remove(menu_items2)
						table.remove(menu_items2)
						if clean_empty == 1 then
							table.remove(menu_items2)
							clean_empty = 0
						end

						table.insert(menu_items2, { select = true,
																widget = notifbox_layout,
																cmd = function(n)

																	if #menu_items2 == 5 then
																		menu_items2 = notifications:clean(style) 
																		clean_empty = 1

																		-- table.remove(menu_items2, n+2)
																		-- local notifbox_layout = wibox.container.constraint(nil, "exact", nil, 115)
																		-- table.insert(menu_items2, n+2, notifbox_layout)

																		self.menu:replace_items(menu_items2)

																		notifications:counter(0)
																		notifications:toggle_menu()
																	else
																		table.remove(menu_items2, n+2)
																		notifications:counter(self.notification_count - 1)
																		self.menu:replace_items(menu_items2)
																	end
																end})

						local menusep = { widget = separator.horizontal(style.separator) }
						table.insert(menu_items2, menusep)
						table.insert(menu_items2, { "Clear log", function()  notifications:toggle_menu() 	menu_items2 = notifications:clean(style) clean_empty = 1 self.menu = newflatmenu({ hide_timeout = 1, theme = style.menu, items = menu_items2 }) notifications:counter(0)  notifications:toggle_menu() notifications:toggle_menu() end, nil, style.micon.close })
						

						self.menu = newflatmenu({ hide_timeout = 1, theme = style.menu, items = menu_items2 })

						-- notifbox_add(n, notif_icon, notifbox_color)
					-- 	awful.spawn.easy_async_with_shell("notify-send 1")
					-- else
					-- 	awful.spawn.easy_async_with_shell("notify-send clicked")
					end
				end
			)
		end

		naughty.connect_signal(
			'request::display',
			function(n)
				notifbox_add_expired(n)
			end
		)
		end


		awesome.connect_signal("widget::dont-disturb", function() notifications:getStatus(true) end)
		notifications:getStatus()
	--awesome.connect_signal("xkb::group_changed", self.update)
end


function notifications:getStatus(toggle)

	local status = newflat.widget.notifications.toggle:status()

	if status then
		for _, w in ipairs(self.objects) do
			w:set_image(disturb_widget_icon_dir .. 'bell-off5.svg')
			if self.notification_count == 0 then
				w:set_color(beautiful.color.main or style.fallback_color)
			end
		end
	else
		for _, w in ipairs(self.objects) do
			w:set_image(notifications.style.icon)
			if self.notification_count == 0 then
				w:set_color(beautiful.color.icon or style.fallback_color)
			end
		end
	end

end

--counter- Notification 
-----------------------------------------------------------------------------------------------------------------------
function notifications:counter(count)
	self.notification_count = count
	if self.notification_count == 1 then
		notifications.tp:set_text(self.notification_count .. " Notification")
	else
		notifications.tp:set_text(self.notification_count .. " Notifications")
	end
end


-- Show layout menu
-----------------------------------------------------------------------------------------------------------------------
function notifications:toggle_menu(x, y)
	if not self.menu then return end

	if self.menu.wibox.visible then
		self.menu:hide()
	else
		awful.placement.under_mouse(self.menu.wibox)
		awful.placement.no_offscreen(self.menu.wibox)
		if x and y then
			self.menu:show({ coords = { x = x, y = y } })
		else
			self.menu:show({ coords = { x = self.menu.wibox.x, y = self.menu.wibox.y } })
		end

	end
	--widg:set_color(notifications.style.layout_color[1])
	notifications:getStatus()
end

-- Create a new keyboard indicator widget
-----------------------------------------------------------------------------------------------------------------------
function notifications.new(style)

	style = style or {}
	if not notifications.menu then notifications:init({}) end

	local widg = svgbox(style.icon or notifications.style.icon)
	widg:set_color(notifications.style.layout_color[1])
	table.insert(notifications.objects, widg)
	notifications.tp:add_to_object(widg)

	notifications.update()
	return widg
end

-- Config metatable to call keybd module as function
-----------------------------------------------------------------------------------------------------------------------
function notifications.mt:__call(...)
	return notifications.new(...)
end

return setmetatable(notifications, notifications.mt)
