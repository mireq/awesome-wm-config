-- awesome_mode: api-level=4:screen=on

pcall(require, "luarocks.loader")

local awful = require("awful")
local battery_utils = require("utils.battery")
local battery_widget = require("widgets.battery_widget")
local beautiful = require("beautiful")
local cairo = require("lgi").cairo
local cyclefocus = require('cyclefocus')
local dpi = beautiful.xresources.apply_dpi
local dpi_watcher = require("widgets.dpi_watcher")
local gdebug = require("gears.debug")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local naughty = require("naughty")
local popups = require("widgets.popups")
local ruled = require("ruled")
local run_shell = require("widgets.run_shell")
local status_magnitude_widget = require("widgets.status_magnitude_widget")
local udisks_mount = require("widgets.udisks_mount")
local utils = require("utils")
local vicious = require("vicious")
local vicious_extra = require("vicious_extra")
local volume_utils = require("utils.volume")
local wibox = require("wibox")
local capi = {
	drawin = drawin,
	root = root,
	awesome = awesome,
	screen = screen
}

local home = os.getenv("HOME")
local confdir = home .. "/.config/awesome"
local themes = confdir .. "/themes"
local active_theme = themes .. "/simple-dark"

--terminal = "alacrittyc"
local terminal = "urxvtc"
local editor = os.getenv("EDITOR")
local gui_editor = "kwrite"
local browser = "firefox-bin"
local tasks = terminal .. " -e htop"
local wireless_settings = "wpa_gui"
local launch_tv = "mpv --demuxer=lavf --demuxer-lavf-format=mpegts --vf=vavpp:deint=auto:interlaced-only=yes --demuxer-lavf-o-add=fflags=+nobuffer --demuxer-lavf-probe-info=nostreams --demuxer-lavf-analyzeduration=0 --force-window=immediate http://192.168.1.111:8001/"

local modkey = "Mod4"
local altkey = "Mod1"

beautiful.init(active_theme .. "/theme_new.lua")

-- {{{ Menu
local menu_accessories = {
	{ "archives", "ark" },
	{ "terminal emulator", terminal },
	{ "file manager", "konqueror" },
	{ "editor", gui_editor },
}
local menu_internet = {
	{ "browser", browser },
}
local menu_games = {
	{ "PSX", "pcsxr" },
	{ "Super NES", "zsnes" },
}
local menu_graphics = {
	{ "gimp" , "gimp" },
	{ "inkscape", "inkscape" },
	{ "darktable" , "darktable" }
}
local menu_office = {
	{ "writer" , "lowriter" },
	{ "impress" , "loimpress" },
}
local menu_system = {
	{ "htop" , terminal .. " -e htop " },
	--{ "htop", 'urxvt -font "xft:DejaVu\\ Sans\\ Mono for Powerline:style=normal:pixelsize=18" -depth 32 -background "rgba:0000/0000/0000/2000" -e htop'},
	{ "hotkeys", function() return false, utils.show_hotkeys_help end},
	{ "quit", function() awesome.quit() end},
	{ "reboot", "loginctl reboot"},
	{ "poweroff", "loginctl poweroff"},
	{ "suspend", "loginctl suspend"}
}
local menu_tv = {
	{ "Jednotka" , launch_tv .. "1:0:1:3B78:C8D:3:EB0000:0:0:0:" },
	{ "Dvojka" , launch_tv .. "1:0:1:3B79:C8D:3:EB0000:0:0:0:" },
	{ "RTVS SPORT HD" , launch_tv .. "1:0:1:3B7B:C8D:3:EB0000:0:0:0:" },
	{ "CT 24" , launch_tv .. "1:0:1:1F43:CA1:3:EB0000:0:0:0:" },
	{ "TA3" , launch_tv .. "1:0:1:1328:CA2:3:EB0000:0:0:0:" },
	{ "HBO" , launch_tv .. "1:0:1:307:C94:3:EB0000:0:0:0:" },
}
local menu_demo = {
	{ "Demo" , 'mpv /home/mirec/video.mkv' },
	{ "Eletctic whiskey" , 'urxvt -font "xft:DejaVu\\ Sans\\ Mono for Powerline:style=normal:pixelsize=16" -depth 32 -background "rgba:0000/0000/0000/8000" -e /home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/7lX3Rj-electric-whiskey.json --resolution 1200x800 --fps 60 --tile-size 600x400' },
	{ "Ether" , 'urxvt -font "xft:DejaVu\\ Sans\\ Mono for Powerline:style=normal:pixelsize=16" -depth 32 -background "rgba:0000/0000/0000/8000" -e /home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/MsjSW3-ether.json --resolution 840x520 --fps 60 --tile-size 420x260' },
	{ "Rounded vornoi borders" , 'urxvt -font "xft:DejaVu\\ Sans\\ Mono for Powerline:style=normal:pixelsize=16" -depth 32 -background "rgba:0000/0000/0000/8000" -e /home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/ll3GRM-rounded-vornoi-borders.json --resolution 960x400 --fps 60 --tile-size 480x200' },
	{ "Seascape" , '/home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/Ms2SD1-seascape.json --resolution 640x360 --fps 30 --tile-size 320x180' },
	{ "Voxel flythrough" , '/home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/MdGXWG-voxel-flythrough.json --resolution 720x400 --tile-size 180x200 --fps 30' },
	{ "Hex voxel scene" , '/home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/4dsBz4-hex-voxel-scene.json --resolution 480x260 --tile-size 240x130 --fps 30' },
	{ "Fractal land" , '/home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/XsBXWt-fractal-land/XsBXWt-fractal-land.json --resolution 640x360 --fps 30 --tile-size 320x180' }
}
local main_menu = {
	items = {
		{ "accessories" , menu_accessories },
		{ "graphics" , menu_graphics },
		{ "internet" , menu_internet },
		{ "games" , menu_games },
		{ "office" , menu_office },
		{ "system" , menu_system },
		{ "tv" , menu_tv },
		{ "demo" , menu_demo },
	},
	theme = {
		height = beautiful.menu_height,
		width = beautiful.menu_width,
		submenu_icon = beautiful.menu_submenu_icon
	}
}

naughty.config.presets.critical.bg = theme.bg_urgent
naughty.config.presets.critical.fg = theme.fg_urgent
naughty.connect_signal("request::display_error", function(message, startup)
	naughty.notification {
		urgency = "critical",
		title = "Error occurred" .. (startup and " during startup" or ""),
		message = message
	}
end)


local function style_menu(menu, s)
	local scaling = utils.float_dpi(1, s)

	return gears.table.join(
		menu,
		{
			theme = {
				height = beautiful.menu_height * scaling,
				width = beautiful.menu_width * scaling,
				submenu_icon = beautiful.menu_submenu_icon
			}
		}
	)
end


local function get_main_menu(s)
	return style_menu(gears.table.clone(main_menu), s)
end



local taglist_common = {}
taglist_common.buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
)


local tasklist_defaults = {}
tasklist_defaults.buttons = gears.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			c.minimized = false
		if not c:isvisible() and c.first_tag then
			c.first_tag:view_only()
		end
			client.focus = c
			c:raise()
		end
	end),
	--awful.button({ }, 3, client_menu_toggle_fn(c)),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
	end)
)

local wireless_buttons = gears.table.join(
	awful.button({ }, 1, function() awful.spawn(wireless_settings) end)
)

for s in screen do
	gears.wallpaper.maximized(beautiful.wallpaper, s, false)
end


local function setup_screen(s)
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end

awful.screen.connect_for_each_screen(setup_screen)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({ }, 3, function()
		local s = awful.screen.focused()
		if s and s.main_menu then
			s.main_menu:toggle()
		end
	end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Key bindings
local globalkeys = gears.table.join(
	awful.key(
		{ modkey }, "h",
		utils.show_hotkeys_help,
		{description = "Show help", group = "Awesome"}
	),
	awful.key(
		{ modkey }, "Left",
		awful.tag.viewprev,
		{description = "View previous", group = "Tag"}
	),
	awful.key(
		{ modkey }, "Right",
		awful.tag.viewnext,
		{description = "View next", group = "Tag"}
	),
	awful.key({ modkey }, "Tab",
		awful.tag.history.restore,
		{description = "Tag history", group = "Tag"}
	),
	awful.key({ modkey }, "j",
		function()
			awful.client.focus.byidx(1)
		end,
		{description = "Focus next", group = "Client"}
	),
	awful.key({ modkey }, "k",
		function()
			awful.client.focus.byidx(-1)
		end,
		{description = "Focus previous", group = "Client"}
	),
	awful.key({ modkey }, "a",
		function()
			awful.prompt.run({
				prompt = " Run Lua code: ",
				textbox = awful.screen.focused().lua_prompt.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval"
			})
		end,
		{description = "Lua prompt", group = "Awesome"}
	),
	awful.key({ modkey }, "r",
		run_shell.launch,
		{description = "Run shell", group = "Awesome"}
	)
)
root.keys(globalkeys)



local clientkeys = gears.table.join(
	awful.key({ altkey }, "Tab",
		function(c)
			cyclefocus.cycle({
				modifier = "Alt_L",
				centered = true
			})
		end,
		{description = "Focus next by history", group = "Client"}
	),
	awful.key({ altkey, 'Shift' }, "Tab",
		function(c)
			cyclefocus.cycle({
				modifier = "Alt_L",
				centered = true
			})
		end,
		{description = "Focus previous by history", group = "Client"}
	)
)
-- }}}


-- Update border size for new client

client.connect_signal("request::manage", function(c)
	if c.border_width then
		local size = dpi(beautiful.border_width, c.screen)
		if size == 0 then
			size = 1
		end
		c.border_width = size
	end

	if not awesome.startup then
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.centered(c, nil)
			awful.placement.no_overlap(c)
		end
		awful.placement.no_offscreen(c)
	end
end)

local function unmaximize_before_move(c)
	if c.fullscreen or c.maximized then
		c.fullscreen = false
		c.maximized = false
		c.width = c.screen.geometry.width
		c.height = c.screen.geometry.height
	end
end


-- {{{ Rules
client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({ }, 1, function (c)
			c:activate { context = "mouse_click" }
		end),
		awful.button({ altkey }, 1, function (c)
			unmaximize_before_move(c)
			c:activate { context = "mouse_click", action = "mouse_move" }
		end),
		awful.button({ altkey }, 3, function (c)
			unmaximize_before_move(c)
			c:activate { context = "mouse_click", action = "mouse_resize"}
		end),
	})
end)

ruled.client.connect_signal("request::rules", function()
	ruled.client.append_rule {
		id = "global",
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			screen = awful.screen.preferred,
		}
	}
	ruled.client.append_rule {
		id = "dialog",
		rule_any = {
			type = { "normal", "dialog" }
		},
		properties = { titlebars_enabled = true }
	}
end)
-- }}}

-- Add a titlebar if titlebars are enabled

client.connect_signal("request::titlebars", function(c)
	local s = c.screen
	local layout

	local buttons = {
		awful.button({ }, 1, function()
			unmaximize_before_move(c)
			c:activate { context = "titlebar", action = "mouse_move" }
		end),
		awful.button({ }, 3, function()
			unmaximize_before_move(c)
			c:activate { context = "titlebar", action = "mouse_resize"}
		end),
	}

	local size_adjust = 0
	if c.border_width ~= 0 then
		size_adjust = 1
	end

	if beautiful.titlebar_position == "top" or beautiful.titlebar_position == "bottom" then
		local window_buttons = {
			close = awful.titlebar.widget.closebutton(c),
			maximized = awful.titlebar.widget.maximizedbutton(c),
			minimize = awful.titlebar.widget.minimizebutton(c),
			ontop = awful.titlebar.widget.ontopbutton(c),
			sticky = awful.titlebar.widget.stickybutton(c),
			floating = awful.titlebar.widget.floatingbutton(c),
		}
		for _, btn in pairs(window_buttons) do
			btn.stylesheet = 'svg { color: '..theme.fg_normal..'; }'
		end
		layout = {
			{ -- Left
				{
					{ -- Icon
						awful.titlebar.widget.iconwidget(c),
						top = dpi(1 - size_adjust, s),
						bottom = dpi(1, s),
						left = dpi(2, s),
						right = dpi(1, s),
						widget = wibox.container.margin,
						buttons = buttons,
					},
					window_buttons.floating,
					window_buttons.sticky,
					window_buttons.ontop,
					layout = wibox.layout.fixed.horizontal
				},
				top = dpi(1 - size_adjust, s),
				bottom = dpi(1, s),
				widget = wibox.container.margin,
			},
			{ -- Middle
				{ -- Title
					halign = "center",
					widget = awful.titlebar.widget.titlewidget(c)
				},
				buttons = buttons,
				fill_space = true,
				layout = wibox.layout.fixed.horizontal
			},
			{ -- Right
				{
					window_buttons.minimize,
					window_buttons.maximized,
					window_buttons.close,
					layout = wibox.layout.fixed.horizontal()
				},
				top = dpi(1 - size_adjust, s),
				bottom = dpi(1, s),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.align.horizontal
		}
	end

	local titlebar = awful.titlebar(c, {position = beautiful.titlebar_position, size = dpi(18 - size_adjust, c.screen)})
	titlebar:set_widget(layout)
end)

client.connect_signal("mouse::enter", function(c)
	c:activate({ context = "mouse_enter", raise = false })
end)

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
	ruled.notification.append_rule {
		rule = { },
		properties = {
			screen = awful.screen.preferred,
			implicit_timeout = 5,
		}
	}
end)

-- }}}

-- {{{ Widget update

local widget_size = {
	temperature = function(s) return utils.calculate_text_width(s, '<span font="'..(theme.temp_font or theme.sensor_font)..'">100 °C</span>') end,
	memory = function(s) return utils.calculate_text_width(s, '<span font="'..(theme.mem_font or theme.sensor_font)..'">99 999 MB </span>') end,
	cpu = function(s) return utils.calculate_text_width(s, '<span font="'..(theme.cpu_font or theme.sensor_font)..'">100 %</span>') end,
	volume = function(s) return utils.calculate_text_width(s, '<span font="'..(theme.cpu_font or theme.sensor_font)..'">100 %</span>') end,
	battery = function(s) return utils.calculate_text_width(s, '<span font="'..(theme.battery_percent_font or theme.sensor_font)..'">100 %</span>') end,
	battery_extended = function(s) return utils.calculate_text_width(s, '<span font="'..(theme.battery_percent_font or theme.sensor_font)..'">100 %</span> <span font="'..(theme.battery_current_font or theme.sensor_font)..'">99.9 W</span>') end,
}

local temperature_gradient = {
	{50, beautiful.fg_normal},
	{60, '#d7d087'},
	{80, '#d78382'},
}
local memory_gradient = {
	{0.4, beautiful.fg_normal},
	{0.6, '#d7d087'},
	{0.8, '#d78382'},
}
local cpu_gradient = {
	{5, beautiful.fg_normal},
	{20, '#d7d087'},
	{60, '#d78382'},
}
local battery_current = {
	status = "Unknown",
	power_now = nil,
	voltage_now = nil,
	energy_now = nil,
	energy_full = nil,
	energy_full_design = nil,
	percentage = nil,
	percentage_exact = nil,
	wear_percentage = nil,
	wear_percentage_exact = nil,
	remaining_seconds = nil,
	time = "N/A",
}
local volume_current = {
	sink_volume = 0,
	sink_mute = true,
}

local update_volume = utils.debounce(function()
	for s in screen do
		for _, w in ipairs(s.volume_widget:get_children_by_id('value')) do
			w:set_markup('<span font="'..(theme.cpu_font or theme.sensor_font)..'">' .. math.floor(volume_current.sink_volume * 100) .. ' %</span>')
		end
		for _, w in ipairs(s.volume_widget:get_children_by_id('icon')) do
			w:set_value(volume_current.sink_volume)
			if volume_current.sink_mute then
				w:set_special("no")
			else
				w:set_special(nil)
			end
		end
	end
end, 0.02, true)


local function on_sink_volume_changed(volume, mute)
	volume_current.sink_volume = volume
	volume_current.sink_mute = mute
	update_volume()
end

volume_utils:connect_signal('master_sink_changed', function(_, args)
	on_sink_volume_changed(args.volume, args.mute)
end)


local function update_widgets()
	vicious.call(
		vicious_extra.network,
		function (widget, args)
			local network_current = args
			local link_quality = args.link_quality
			if link_quality ~= 0 then
				link_quality = link_quality * 1.2 + 0.1
			end
			for s in screen do
				if link_quality == 0 then
					s.wifi_widget:set_special('no')
				else
					s.wifi_widget:set_special(nil)
					s.wifi_widget:set_value(link_quality)
				end
			end
		end
	)

	vicious.call(
		vicious.widgets.thermal,
		function (widget, args)
			local temp = args[1]
			local color = utils.calculate_gradient_color(temp, temperature_gradient)
			for s in screen do
				for _, w in ipairs(s.temperature_widget:get_children_by_id('icon')) do
					w.stylesheet = 'svg { fill: '..color..'; }'
				end
				for _, w in ipairs(s.temperature_widget:get_children_by_id('value')) do
					w:set_markup('<span font="'..(theme.temp_font or theme.sensor_font)..'">' .. temp .. ' °C</span>')
				end
			end
		end,
		{"thermal_zone0", "sys"}
	)

	vicious.call(
		vicious.widgets.mem,
		function (widget, args)
			local used = args[2]
			local total = args[3]
			local percentage = used / total
			local color = utils.calculate_gradient_color(percentage, memory_gradient)
			for s in screen do
				for _, w in ipairs(s.memory_widget:get_children_by_id('icon')) do
					w.stylesheet = 'svg { fill: '..color..'; }'
				end
				for _, w in ipairs(s.memory_widget:get_children_by_id('value')) do
					w:set_markup('<span font="'..(theme.mem_font or theme.sensor_font)..'">' .. utils.format_number(used) .. ' MB</span>')
				end
			end
		end
	)

	vicious.call(
		vicious.widgets.cpu,
		function (widget, args)
			local value = args[1]
			local color = utils.calculate_gradient_color(value, cpu_gradient)
			for s in screen do
				for _, w in ipairs(s.cpu_widget:get_children_by_id('icon')) do
					w.stylesheet = 'svg { fill: '..color..'; }'
				end
				for _, w in ipairs(s.cpu_widget:get_children_by_id('value')) do
					w:set_markup('<span font="'..(theme.cpu_font or theme.sensor_font)..'">' .. value .. ' %</span>')
				end
			end
		end
	)
	vicious.call(
		vicious_extra.bat,
		function (widget, args)
			battery_current = args

			if battery_current.percentage == nil then
				return ''
			end

			local text = '<span font="'..(theme.battery_percent_font or theme.sensor_font)..'">'..battery_current.percentage..' %</span>'
			if battery_current.power_now and battery_current.power_now > 0 then
				text = text .. ' <span font="'..(theme.battery_current_font or theme.sensor_font)..'" alpha="50%">'..string.format("%.1f", battery_current.power_now)..' W</span>'
			end

			battery_utils.record(battery_current)

			for s in screen do
				for _, w in ipairs(s.battery_widget:get_children_by_id('value')) do
					if battery_current.power_now and battery_current.power_now > 0 then
						w:set_forced_width(widget_size.battery_extended(s))
					else
						w:set_forced_width(widget_size.battery(s))
					end
					w:set_markup(text)
				end
				for _, w in ipairs(s.battery_widget:get_children_by_id('icon')) do
					w:set_value(battery_current.percentage_exact / 100)
					if battery_current.status == "Charging" then
						w:set_bar_color("#63b5f6")
						w:set_options({
							stylesheet = 'svg { color: '..theme.fg_normal..'; }'
						})
					elseif battery_current.status == "Discharging" then
						if battery_current.percentage_exact < 30 then
							w:set_bar_color("#e33a35")
							w:set_options({
								stylesheet = 'svg { color: #d78382; }'
							})
						else
							w:set_bar_color("#4cb050")
							w:set_options({
								stylesheet = 'svg { color: '..theme.fg_normal..'; }'
							})
						end
						if battery_current.percentage_exact < 5 then
							naughty.notify({
								text = battery_current.percentage .. '%',
								title = "Battery empty!",
								position = "top_right",
								timeout = 1,
								preset = naughty.config.presets.critical,
								screen = 1,
								ontop = true,
							})
						elseif battery_current.percentage_exact < 10 then
							naughty.notify({
								text = battery_current.percentage .. '%',
								title = "Battery low",
								position = "top_right",
								timeout = 1,
								screen = 1,
								ontop = true,
							})
						end
					end
				end
			end
		end,
		'BAT0'
	)
	update_volume()
end
-- }}}



local battery_tooltip_common = {
	timeout = 5,
	timer_function = function()
		vicious.force({ battery_widget })
		local tooltip_text = '<span font="'..theme.font..'" color="'..theme.fg_normal..'">Status: <b><span color="'..theme.fg_accent..'">'..battery_current.status..'</span></b></span>'
		if battery_current.time and battery_current.time ~= "N/A" then
			tooltip_text = tooltip_text .. '\n<span font="'..theme.font..'" color="'..theme.fg_normal..'">Remaining time: <b><span color="'..theme.fg_accent..'">'..battery_current.time..'</span></b></span>'
		end
		if battery_current.power_now and battery_current.power_now > 0 then
			tooltip_text = tooltip_text .. '\n<span font="'..theme.font..'" color="'..theme.fg_normal..'">Power: <b><span color="'..theme.fg_accent..'">'..string.format("%.2f", battery_current.power_now)..' W</span></b></span>'
		end
		if battery_current.energy_now then
			tooltip_text = tooltip_text .. '\n<span font="'..theme.font..'" color="'..theme.fg_normal..'">Energy: <b><span color="'..theme.fg_accent..'">'..string.format("%.1f", battery_current.energy_now)..' Wh</span></b></span>'
		end
		return tooltip_text
	end
}


gears.timer {
	timeout   = 10,
	call_now  = false,
	autostart = true,
	single_shot = false,
	callback  = update_widgets
}
-- }}}


local function set_screen_dpi(s, new_dpi)
	s.dpi = new_dpi

	local scaling = utils.float_dpi(1, s)
	local taglist_size = dpi(6, s)
	local taglist_margin = dpi(1, s)

	s.tool_bar.height = dpi(18, s)

	s.taglist_args.style = {
		squares_sel = utils.render_svg(beautiful.taglist_squares_sel, scaling),
		squares_unsel = utils.render_svg(beautiful.taglist_squares_unsel, scaling),
	}
	utils.update_widget_template_attributes(s.taglist_args.widget_template, {
		container_role = {
			forced_width = taglist_size,
			forced_height = taglist_size,
		},
		margin_role = {
			bottom = taglist_margin,
			right = taglist_margin,
		},
	})
	s.taglist:set_widget_template(s.taglist_args.widget_template)

	s.tasklist_args.layout.max_widget_size = dpi(240, s)
	s.tasklist_args.layout.spacing = dpi(0, s)
	utils.update_widget_template_attributes(s.tasklist_args.widget_template, {
		icon_margins_role = {
			top = dpi(1, s),
			bottom = dpi(1, s),
			left = dpi(2, s),
		},
		text_margin_role = {
			left = dpi(2, s),
			right = dpi(4, s),
		},
		background_border_role = {
			top = dpi(1, s),
		}
	})
	s.tasklist:set_widget_template(s.tasklist_args.widget_template)

	s.main_menu:hide()
	s.main_menu = awful.menu(get_main_menu(s))

	s.launcher:set_image(utils.render_svg(theme.launch, scaling))

	s.taglist:set_base_layout(s.taglist_args.layout)
	s.tasklist:set_base_layout(s.tasklist_args.layout)

	for s in screen do
		for _, w in ipairs(s.temperature_widget:get_children_by_id('value')) do
			w:set_forced_width(widget_size.temperature(s))
		end
		for _, w in ipairs(s.memory_widget:get_children_by_id('value')) do
			w:set_forced_width(widget_size.memory(s))
		end
		for _, w in ipairs(s.cpu_widget:get_children_by_id('value')) do
			w:set_forced_width(widget_size.cpu(s))
		end
		for _, w in ipairs(s.battery_widget:get_children_by_id('value')) do
			if battery_current.power_now and battery_current.power_now > 0 then
				w:set_forced_width(widget_size.battery_extended(s))
			else
				w:set_forced_width(widget_size.battery(s))
			end
		end
		for _, w in ipairs(s.volume_widget:get_children_by_id('value')) do
			w:set_forced_width(widget_size.volume(s))
		end
	end

	local border_size = dpi(beautiful.border_width, s)
	if border_size == 0 then
		border_size = 1
	end
	for _, c in ipairs(s.clients) do
		if c.border_width then
			c.border_width = border_size
		end
		c:emit_signal("request::titlebars")
	end
end

local function draw_wibar_background(context, cr, width, height)
	local s = context.screen
	local gradient_stops = ''
	local gradient_pos = 0.0
	if beautiful.wibar_border_top ~= nil then
		gradient_stops = gradient_stops .. ':' .. tostring(gradient_pos) .. ',' .. beautiful.wibar_border_top
		gradient_pos = gradient_pos + utils.float_dpi(1.5, s) / height
	end
	if beautiful.wibar_border_top ~= nil or beautiful.wibar_border_bottom ~= nil or beautiful.wibar_bg_bottom ~= nil then
		gradient_stops = gradient_stops .. ':' .. tostring(gradient_pos) .. ',' .. beautiful.wibar_bg
		if beautiful.wibar_bg_bottom ~= nil then
			gradient_pos = 1 - utils.float_dpi(1.5, s) / height
			gradient_stops = gradient_stops .. ':' .. tostring(gradient_pos) .. ',' .. beautiful.wibar_bg_bottom
		end
		gradient_pos = 1
		if beautiful.wibar_border_bottom ~= nil then
			gradient_stops = gradient_stops .. ':' .. tostring(gradient_pos) .. ',' .. beautiful.wibar_border_bottom
		end
	end

	if gradient_stops ~= '' then
		cr:set_source(gears.color('linear:0,0:0,'..height..gradient_stops))
	else
		cr:set_source(gears.color(beautiful.wibar_bg or beautiful.bg_normal))
	end
	cr:rectangle(0, 0, width, height)
	cr:fill()
end


screen.connect_signal("request::desktop_decoration", function(s)
	local scaling = utils.float_dpi(1, s)

	-- main panel
	s.tool_bar = awful.wibar({
		position = "top",
		screen = s,
		height = dpi(18, s),
		bgimage = draw_wibar_background
	})

	s.main_menu = awful.menu(get_main_menu(s))

	s.launcher = awful.widget.launcher({
		image = beautiful.launch,
		menu = s.main_menu
	})
	s.launcher:set_image(utils.render_svg(theme.launch, scaling))
	s.launcher:set_buttons(gears.table.join(
		awful.button({ }, 1, function() s.main_menu:toggle() end)
	))

	s.taglist_args = {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = gears.table.join(taglist_common.buttons),
		style = {
			squares_sel = utils.render_svg(beautiful.taglist_squares_sel, scaling),
			squares_unsel = utils.render_svg(beautiful.taglist_squares_unsel, scaling),
		},
		layout = {
			spacing = 0,
			layout  = wibox.layout.grid,
			forced_num_cols = 3,
			forced_num_rows = 3,
		},
		widget_template = {
			id = "container_role",
			widget = dpi_watcher,
			forced_width = dpi(6, s),
			forced_height = dpi(6, s),
			{
				{
					{
						id = "background_role",
						widget = wibox.container.background,
					},
					{
						top = 1000, -- not visible
						widget = wibox.container.margin,
						{
							id = "text_role",
							widget = wibox.widget.textbox,
						}
					},
					{
						id = "icon_role",
						widget = wibox.widget.imagebox,
						forced_width = dpi(6, s),
						forced_height = dpi(6, s),
						resize = true,
					},
					widget = wibox.container.margin,
				},
				id = "margin_role",
				bottom = dpi(1, s),
				right = dpi(1, s),
				widget = wibox.container.margin
			},
			dpi_callback = function(w)
				local taglist_size = dpi(6, s)
				local taglist_margin = dpi(1, s)
				w.forced_width = taglist_size
				w.forced_height = taglist_size
				local margin_widget = w:get_children()[1]
				margin_widget.bottom = taglist_margin
				margin_widget.right = taglist_margin
				local icon_widget = w:get_children_by_id('icon_role')[1]
				icon_widget.forced_width = taglist_size
				icon_widget.forced_height = taglist_size
			end,
		},
	}

	s.taglist = awful.widget.taglist(s.taglist_args)

	s.tasklist_args = {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_defaults.buttons,
		layout = {
			max_widget_size = dpi(240, s),
			spacing = dpi(0, s),
			layout = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					{
						id = "background_role",
						widget = wibox.container.background,
						forced_height = dpi(1, s)
					},
					{
						id = "background_shading_role",
						widget = wibox.container.background,
						bg = '#00000000',
					},
					fill_space = true,
					widget = wibox.layout.fixed.vertical,
				},
				{
					{
						{
							id = 'client_icon_role',
							widget = awful.widget.clienticon,
						},
						id = 'icon_margins_role',
						top = dpi(1, s),
						bottom = dpi(1, s),
						left = dpi(2, s),
						widget = wibox.container.margin,
					},
					{
						{
							id = 'text_role',
							widget = wibox.widget.textbox,
						},
						id = 'text_margin_role',
						left = dpi(2, s),
						right = dpi(4, s),
						widget = wibox.container.margin,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				layout = wibox.layout.stack,
			},
			update_common = function(self, c, index, objects)
				local widgets = self:get_children_by_id('background_shading_role')
				local bg = '#00000000'
				local icon_opacity = beautiful.tasklist_icon_opacity_normal or 1
				if c.active then
					bg = beautiful.tasklist_bg_focus or beautiful.bg_focus or bg_normal
					icon_opacity = beautiful.tasklist_icon_opacity_focus or 1
				elseif c.urgent then
					bg = beautiful.tasklist_bg_urgent or beautiful.bg_urgent or bg_normal
					icon_opacity = beautiful.tasklist_icon_opacity_focus or 1
				end
				bg = utils.set_color_alpha(bg, beautiful.tasklist_bg_opacity or 0.2)
				for _, w in ipairs(widgets) do
					w:set_bg(bg)
				end
				widgets = self:get_children_by_id('client_icon_role')
				for _, w in ipairs(widgets) do
					w:set_opacity(icon_opacity)
				end
			end,
			create_callback = function(self, c, index, objects)
				self.client = c
				if c.icon == nil then
					local widgets = self:get_children_by_id('icon_margins_role')
					for _, w in ipairs(widgets) do
						w:set_left(0)
					end
				end
				self.update_common(self, c, index, objects)
			end,
			update_callback = function(self, c, index, objects)
				self.update_common(self, c, index, objects)
			end,
			dpi_callback = function(w)
				local widgets = w:get_children_by_id('icon_margins_role')
				local c = w.client
				for _, w in ipairs(widgets) do
					w:set_top(dpi(1, s))
					w:set_bottom(dpi(1, s))
					if c and c.icon then
						w:set_left(dpi(1, s))
					else
						w:set_left(0)
					end
				end
				widgets = w:get_children_by_id('background_role')
				for _, w in ipairs(widgets) do
					w:set_forced_height(dpi(1, s))
				end
			end,
			widget = dpi_watcher,
		},
	}
	s.tasklist = awful.widget.tasklist(s.tasklist_args)
	s.lua_prompt = awful.widget.prompt()
	s.wifi_widget = status_magnitude_widget({
		icon = beautiful.widget_wireless,
		count = beautiful.widget_wireless_count,
		special = {'no'},
		stylesheet = 'svg { color: '..theme.fg_normal..'; }'
	})
	s.wifi_widget:set_buttons(wireless_buttons)
	popups.netstat(s.wifi_widget, {
		title_color = "#ffffff",
		established_color = "#ffff00",
		listen_color = "#00ff00"
	})

	s.temperature_widget = wibox.widget({
		{
			id = 'icon',
			image = beautiful.widget_temp,
			stylesheet = 'svg { fill: '..theme.fg_normal..'; }',
			widget = wibox.widget.imagebox
		},
		{
			id = 'value',
			text = '',
			widget = wibox.widget.textbox,
			forced_width = widget_size.temperature(s)
		},
		layout = wibox.layout.fixed.horizontal
	})
	s.memory_widget = wibox.widget({
		{
			id = 'icon',
			image = beautiful.widget_mem,
			stylesheet = 'svg { fill: '..theme.fg_normal..'; }',
			widget = wibox.widget.imagebox
		},
		{
			id = 'value',
			text = '',
			widget = wibox.widget.textbox,
			forced_width = widget_size.memory(s)
		},
		layout = wibox.layout.fixed.horizontal
	})
	s.cpu_widget = wibox.widget({
		{
			id = 'icon',
			image = beautiful.widget_cpu,
			stylesheet = 'svg { fill: '..theme.fg_normal..'; }',
			widget = wibox.widget.imagebox
		},
		{
			id = 'value',
			text = '',
			widget = wibox.widget.textbox,
			forced_width = widget_size.cpu(s)
		},
		layout = wibox.layout.fixed.horizontal
	})
	popups.htop(s.cpu_widget, {
		title_color = "#ffffff",
		user_color = "#00ff00",
		root_color = "#ffff00",
		terminal = "urxvt"
	})
	s.battery_widget = wibox.widget({
		{
			id = 'icon',
			options = {
				stylesheet = 'svg { color: '..theme.fg_normal..'; }',
			},
			widget = battery_widget
		},
		{
			id = 'value',
			text = '',
			widget = wibox.widget.textbox,
			forced_width = widget_size.battery(s)
		},
		layout = wibox.layout.fixed.horizontal
	})
	s.battery_tooltip = awful.tooltip(battery_tooltip_common)
	s.battery_tooltip:add_to_object(s.battery_widget)

	s.volume_widget = wibox.widget({
		{
			id = 'icon',
			options = {
				icon = beautiful.widget_volume,
				count = beautiful.widget_volume_count,
				special = {'no'},
				stylesheet = 'svg { color: '..theme.fg_normal..'; }',
			},
			special = 'no',
			widget = status_magnitude_widget
		},
		{
			id = 'value',
			text = '',
			widget = wibox.widget.textbox,
			forced_width = widget_size.volume(s)
		},
		layout = wibox.layout.fixed.horizontal
	})

	local function on_mount(path, err)
		if err then
			naughty.notify({
				preset = naughty.config.presets.critical,
				text = tostring(err),
			})
		else
			if path ~= nil and filemanager ~= nil then
				awful.spawn({filemanager, path})
			end
		end
	end

	local function on_unmount(path, err)
		if err then
			naughty.notify({
				preset = naughty.config.presets.critical,
				text = tostring(err),
			})
		end
	end

	s.udisks_mount = udisks_mount({
		screen = s,
		stylesheet = 'svg { color: ' .. theme.fg_normal .. '; }',
		buttons = gears.table.join(
			awful.button({ }, 1, function(dev)
				udisks_mount.mount(dev, function(path, dev, err)
					on_mount(path, err)
				end)
			end),
			awful.button({ }, 3, function(dev)
				local menu = {}
				local open_label = "Open"
				if not dev['Mounted'] then
					open_label = "Mount"
				end
				table.insert(menu, {open_label, function()
					udisks_mount.mount(dev, function(path, dev, err)
						on_mount(path, err)
					end)
				end})
				if dev['Drive']['Ejectable'] then
					table.insert(menu, {"Eject", function()
						udisks_mount.unmount_and_eject(dev, function(path, dev, err)
							on_unmount(path, err)
						end)
					end})
				end
				if dev['Mounted'] then
					table.insert(menu, {"Unmount", function()
						udisks_mount.unmount(dev, function(path, dev, err)
							on_unmount(path, err)
						end)
					end})
				end

				menu = style_menu(menu, s)

				awful.menu(menu):show()
			end)
		)
	})

	s.tool_bar:setup({
		{
			s.launcher,
			s.taglist,
			s.lua_prompt,
			layout = wibox.layout.fixed.horizontal
		},
		s.tasklist,
		{
			s.temperature_widget,
			s.memory_widget,
			s.cpu_widget,
			s.battery_widget,
			s.volume_widget,
			s.wifi_widget,
			s.udisks_mount,
			layout = wibox.layout.fixed.horizontal
		},
		layout = wibox.layout.align.horizontal
	})

	update_widgets()
end)

volume_utils.start_monitor()


local collect_garbage = utils.debounce(function()
	collectgarbage("collect")
end, 0.5, false)


screen.connect_signal("list", function()
	collect_garbage()
end)


awful.run_test = function()
	--s = screen.fake_add(20, 20, 500, 400)
	for s in screen do
		set_screen_dpi(s, 384)
	end
	gears.timer {
		timeout   = 0.05,
		call_now  = false,
		autostart = true,
		single_shot = true,
		callback  = function()
			--set_screen_dpi(s, 384)
			for s in screen do
				set_screen_dpi(s, 192)
			end
			--s:fake_remove()
			--utils.show_hotkeys_help()
			collectgarbage("collect")
		end
	}
	--widgets = {}
	--for s in screen do
	--	for i=0, 10 do
	--		w = awful.wibar({
	--			position = "top",
	--			screen = s,
	--			height = dpi(1, s),
	--			bg = '#ff0000',
	--			visible = true
	--		})
	--		table.insert(widgets, w)
	--	end
	--end
	--gears.timer {
	--	timeout   = 0.05,
	--	call_now  = false,
	--	autostart = true,
	--	single_shot = true,
	--	callback  = function()
	--		for _, w in ipairs(widgets) do
	--			w:remove()
	--		end
	--		widgets = {}
	--		collectgarbage("collect")
	--	end
	--}
end
awful.run_test()


awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = true
