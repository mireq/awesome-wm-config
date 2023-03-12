pcall(require, "luarocks.loader")

local gears = require("gears")
local gdebug = require("gears.debug")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local utils = require("utils")
local vicious = require("vicious")
local vicious_extra = require("vicious_extra")
local cairo = require("lgi").cairo
local run_shell = require("widgets.run_shell")
local popups = require("widgets.popups")
local dpi_watcher = require("widgets.dpi_watcher")
local status_magnitude_widget = require("widgets.status_magnitude_widget")
local dpi = beautiful.xresources.apply_dpi
local hotkeys_popup = require("awful.hotkeys_popup")
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


local function float_dpi(size, s)
	local ratio = s.dpi / 96
	return size * ratio
end


local function get_main_menu(s)
	local scaling = float_dpi(1, s)

	return gears.table.join(
		gears.table.clone(main_menu),
		{
			theme = {
				height = beautiful.menu_height * scaling,
				width = beautiful.menu_width * scaling,
				submenu_icon = beautiful.menu_submenu_icon
			}
		}
	)
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
		function ()
			awful.client.focus.byidx(1)
		end,
		{description = "Focus next", group = "Client"}
	),
	awful.key({ modkey }, "k",
		function ()
			awful.client.focus.byidx(-1)
		end,
		{description = "Focus previous", group = "Client"}
	),
	awful.key({ modkey }, "a",
		function ()
			awful.prompt.run({
				prompt = " Run Lua code: ",
				textbox = awful.screen.focused().lua_prompt.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval"
			})
		end,
		{description = "Lua prompt", group = "Awesome"}
	),
	awful.key({modkey}, "r",
		run_shell.launch,
		{description = "run shell", group = "Awesome"}
	)
)
root.keys(globalkeys)
-- }}}


-- {{{ Widget update

local temperature_gradient = {
	{50, beautiful.fg_normal},
	{60, '#d7d087'},
	{80, '#d78382'},
}

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
			end
		end,
		{"thermal_zone0", "sys"}
	)
end
-- }}}


gears.timer {
	timeout   = 10,
	call_now  = false,
	autostart = true,
	single_shot = false,
	callback  = update_widgets
}
-- }}}


--screen.connect_signal("list", function()
--	print("list signal")
--end)
--
local function set_screen_dpi(s, new_dpi)
	s.dpi = new_dpi

	local scaling = float_dpi(1, s)
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
	s.tasklist_args.layout.spacing = dpi(8, s)
	utils.update_widget_template_attributes(s.tasklist_args.widget_template, {
		icon_margin_role = {
			top = dpi(1, s),
			bottom = dpi(1, s),
			left = dpi(2, s),
		},
		text_margin_role = {
			left = dpi(2, s),
		}
	})
	s.tasklist:set_widget_template(s.tasklist_args.widget_template)

	s.main_menu:hide()
	s.main_menu = awful.menu(get_main_menu(s))

	s.launcher:set_image(utils.render_svg(theme.launch, scaling))

	s.taglist:set_base_layout(s.taglist_args.layout)
	s.tasklist:set_base_layout(s.tasklist_args.layout)
end

screen.connect_signal("request::desktop_decoration", function(s)
	local scaling = float_dpi(1, s)

	-- main panel
	s.tool_bar = awful.wibar({
		position = "top",
		screen = s,
		height = dpi(18, s),
		bgimage = function(context, cr, width, height)
			local gradient_stops = ''
			local gradient_pos = 0.0
			if beautiful.wibar_border_top ~= nil then
				gradient_stops = gradient_stops .. ':' .. tostring(gradient_pos) .. ',' .. beautiful.wibar_border_top
				gradient_pos = gradient_pos + float_dpi(1.5, s) / height
			end
			if beautiful.wibar_border_top ~= nil or beautiful.wibar_border_bottom ~= nil or beautiful.wibar_bg_bottom ~= nil then
				gradient_stops = gradient_stops .. ':' .. tostring(gradient_pos) .. ',' .. beautiful.wibar_bg
				if beautiful.wibar_bg_bottom ~= nil then
					gradient_pos = 1 - float_dpi(1.5, s) / height
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
			spacing = dpi(8, s),
			layout = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					{
						widget = awful.widget.clienticon,
					},
					id = 'icon_margin_role',
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
					widget = wibox.container.margin,
				},
				layout = wibox.layout.fixed.horizontal,
			},
			create_callback = function(self, c, index, objects)
				self.client = c
				if c.icon == nil then
					local widgets = self:get_children_by_id('icon_margin_role')
					for _, w in ipairs(widgets) do
						w:set_left(0)
					end
				end
			end,
			dpi_callback = function(w)
				local widgets = w:get_children_by_id('icon_margin_role')
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
			end,
			widget = dpi_watcher,
		},
	}
	s.tasklist = awful.widget.tasklist(s.tasklist_args)
	s.lua_prompt = awful.widget.prompt()
	s.wifi_widget = status_magnitude_widget({
		icon = beautiful.widget_wireless,
		count = 4,
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
		layout = wibox.layout.fixed.horizontal
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
			s.wifi_widget,
			s.temperature_widget,
			layout = wibox.layout.fixed.horizontal
		},
		layout = wibox.layout.align.horizontal
	})

	update_widgets()
end)

awful.run_test = function()
	--s = screen.fake_add(20, 20, 500, 400)
	for s in screen do
		set_screen_dpi(s, 384)
	end
	gears.timer {
		timeout   = 0.5,
		call_now  = false,
		autostart = true,
		single_shot = true,
		callback  = function()
			--set_screen_dpi(s, 384)
			for s in screen do
				set_screen_dpi(s, 192)
			end
			--s:fake_remove()
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

