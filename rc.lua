-- awesome_mode: api-level=4:screen=on
pcall(require, "luarocks.loader")


local api = require("api")
local awful = require("awful")
local beautiful = require("beautiful")
local cairo = require("lgi").cairo
local cyclefocus = require('cyclefocus')
local dpi = beautiful.xresources.apply_dpi
local gdebug = require("gears.debug")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local naughty = require("naughty")
local popups = require("widgets.popups")
local ruled = require("ruled")
local udisks_mount = require("awesome-udisks2-mount.udisks")
local utils = require("utils")
local vicious = require("vicious")
local vicious_extra = require("vicious_extra")
local wibox = require("wibox")
local widgets = require("widgets")
require("awful.autofocus")
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
local filemanager = "konqueror"

local modkey = "Mod4"
local altkey = "Mod1"

beautiful.init(active_theme .. "/theme.lua")

-- {{{ Menu

local loaded, menu_items = pcall(require, "menu_items")
if not loaded then
	menu_items = nil
end

if menu_items == nil then
	local menu_accessories = {
		{ "archives", "ark" },
		{ "terminal emulator", terminal },
		{ "file manager", "konqueror" },
		{ "editor", gui_editor },
	}
	local menu_internet = {
		{ "browser", browser },
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
		{ "hotkeys", function() return false, utils.show_hotkeys_help end},
		{ "quit", function() awesome.quit() end},
		{ "reboot", "loginctl reboot"},
		{ "poweroff", "loginctl poweroff"},
		{ "suspend", "loginctl suspend"}
	}
	menu_items = {
		{ "accessories" , menu_accessories },
		{ "graphics" , menu_graphics },
		{ "internet" , menu_internet },
		{ "office" , menu_office },
		{ "system" , menu_system },
	}
end

local main_menu = {
	items = menu_items,
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
		preset = naughty.config.presets.critical,
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


tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
		awful.layout.suit.floating,
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		-- awful.layout.suit.fair,
		-- awful.layout.suit.fair.horizontal,
		-- awful.layout.suit.spiral,
		-- awful.layout.suit.spiral.dwindle,
		-- awful.layout.suit.max,
		-- awful.layout.suit.max.fullscreen,
		-- awful.layout.suit.magnifier,
		-- awful.layout.suit.corner.nw,
	})
end)


local function volume_command(mode)
	if mode == "up" then
		utils.volume.sink_change(0.01)
	elseif mode == "down" then
		utils.volume.sink_change(-0.01)
	elseif mode == "mute" then
		utils.volume.sink_mute_toggle()
	elseif mode == "micmute" then
		utils.volume.source_mute_toggle()
	end
end


local layoutbox_common = {}
layoutbox_common.buttons = gears.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () awful.layout.inc(-1) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

local taglist_common = {}
taglist_common.buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
)

local volume_common = {}
volume_common.buttons = gears.table.join(
	awful.button({ }, 4, function () volume_command("up") end),
	awful.button({ }, 5, function () volume_command("down") end),
	awful.button({ }, 1, function () volume_command("mute") end)
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

local function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, false)
	end
end

screen.connect_signal("request::wallpaper", set_wallpaper)


local system_suspend = utils.debounce(function()
	awful.spawn("loginctl suspend")
end, 0.1, false)

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
awful.keyboard.append_global_keybindings({
	awful.key(
		{ modkey }, "s",
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
		widgets.run_shell.launch,
		{description = "Run shell", group = "Awesome"}
	),
	awful.key({ modkey }, "w",
		function () awful.screen.focused().main_menu:show() end,
		{description = "Show main menu", group = "Awesome"}
	),
	awful.key({ modkey, "Shift" }, "j",
		function()
			awful.client.focus.byidx(1)
		end,
		{description = "Swap with next client", group = "Client"}
	),
	awful.key({ modkey, "Shift" }, "k",
		function()
			awful.client.focus.byidx(-1)
		end,
		{description = "Swap with previous client", group = "Client"}
	),
	awful.key({ modkey }, "u",
		awful.client.urgent.jumpto,
		{description = "Jump to urgent client", group = "Client"}
	),
	awful.key({ modkey, "Control" }, "j",
		function()
			awful.screen.focus_relative(1)
		end,
		{description = "Focus next screen", group = "Screen"}
	),
	awful.key({ modkey, "Control" }, "k",
		function()
			awful.screen.focus_relative(-1)
		end,
		{description = "Focus previous screen", group = "Screen"}
	),
	awful.key({ modkey }, "Return",
		function()
			awful.spawn(terminal)
		end,
		{description = "Run terminal", group = "Launcher"}
	),
	awful.key({ modkey, "Control" }, "F7",
		function()
			awful.spawn("/etc/acpi/actions/switchvideo.sh")
		end,
		{description = "Switch videou output", group = "Launcher"}
	),
	awful.key({ modkey, "Shift" }, "r",
		awesome.restart,
		{description = "Restart awesome", group = "Awesome"}
	),
	awful.key({ modkey, "Control", "Shift" }, "q",
		awesome.restart,
		{description = "Quit awesome", group = "Awesome"}
	),
	awful.key({ modkey, "Shift" }, "s",
		system_suspend,
		{description = "Sleep mode", group = "Awesome"}
	),
	awful.key({ modkey }, "l",
		function()
			awful.tag.incmwfact( 0.05)
		end,
		{description = "Increase master width factor", group = "Layout"}
	),
	awful.key({ modkey }, "h",
		function()
			awful.tag.incmwfact(-0.05)
		end,
		{description = "Decrease master width factor", group = "Layout"}
	),
	awful.key({ modkey, "Shift" }, "l",
		function()
			awful.tag.incnmaster(1, nil, true)
		end,
		{description = "Increase the number of master clients", group = "Layout"}
	),
	awful.key({ modkey, "Shift" }, "h",
		function()
			awful.tag.incnmaster(-1, nil, true)
		end,
		{description = "Decrease the number of master clients", group = "Layout"}
	),
	awful.key({ modkey, "Control" }, "l",
		function()
			awful.tag.incnmaster(1, nil, true)
		end,
		{description = "Increase the number of columns", group = "Layout"}
	),
	awful.key({ modkey, "Control" }, "h",
		function()
			awful.tag.incnmaster(-1, nil, true)
		end,
		{description = "Decrease the number of columns", group = "Layout"}
	),
	awful.key({ modkey }, "space",
		function()
			awful.layout.inc(1)
		end,
		{description = "Next layout", group = "Layout"}
	),
	awful.key({ modkey, "Shift" }, "space",
		function()
			awful.layout.inc(-1)
		end,
		{description = "Previous layout", group = "Layout"}
	),
	awful.key({ modkey, "Control" }, "n",
		function ()
			local c = awful.client.restore()
			if c then
				c:activate { raise = true, context = "key.unminimize" }
			end
		end,
		{description = "Restore minimized client", group = "Client"}
	),
	awful.key({ modkey }, "p",
		function()
			menubar.show()
		end,
		{description = "Show menubar", group = "Launcher"}
	),
	awful.key({ modkey, altkey, "Shift" }, "r",
		function ()
			awful.spawn("/usr/local/bin/record_desktop_toggle")
		end,
		{description = "Record desktop", group = "Launcher"}
	),
	awful.key({ }, "XF86AudioRaiseVolume", function () volume_command("up") end),
	awful.key({ }, "XF86AudioLowerVolume", function () volume_command("down") end),
	awful.key({ }, "XF86AudioMute", function () volume_command("mute") end),
	awful.key({ }, "XF86AudioMicMute", function () volume_command("micmute") end)
})


-- Number key bindings
awful.keyboard.append_global_keybindings({
	awful.key {
		modifiers = { modkey },
		keygroup = "numrow",
		description = "Only view tag",
		group = "Tag",
		on_press = function (index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	},
	awful.key {
		modifiers = { modkey, "Control" },
		keygroup = "numrow",
		description = "Toggle tag",
		group = "Tag",
		on_press = function (index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	},
	awful.key {
		modifiers = { modkey, "Shift" },
		keygroup = "numrow",
		description = "Move focused client to tag",
		group = "Tag",
		on_press = function (index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	},
	awful.key {
		modifiers = { modkey, "Control", "Shift" },
		keygroup = "numrow",
		description = "Toggle focused client on tag",
		group = "Tag",
		on_press = function (index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	},
	awful.key {
		modifiers = { modkey },
		keygroup = "numpad",
		description = "Select layout directly",
		group = "Layout",
		on_press = function (index)
			local t = awful.screen.focused().selected_tag
			if t then
				t.layout = t.layouts[index] or t.layout
			end
		end,
	}
})



-- }}}



local function unmaximize_before_move(c)
	if c.fullscreen or c.maximized then
		c.fullscreen = false
		c.maximized = false
		c.width = c.screen.geometry.width
		c.height = c.screen.geometry.height
	end
end


-- {{{ Client bindings
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

local function is_focusable(c, source_c)
	return c.focusable
end


local function has_titlebar(c)
	for __, pos in ipairs({'left', 'right', 'top', 'bottom'}) do
		local __, size = c['titlebar_' .. pos](c)
		if size > 0 then
			return true
		end
	end
	return false
end


client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		awful.key({ altkey }, "Tab",
			function(c)
				cyclefocus.cycle({
					modifier = "Alt_L",
					cycle_filters = { is_focusable, cyclefocus.filters.same_screen, cyclefocus.filters.common_tag },
					centered = true
				})
			end,
			{description = "Focus next by history", group = "Client"}
		),
		awful.key({ altkey, 'Shift' }, "Tab",
			function(c)
				cyclefocus.cycle({
					modifier = "Alt_L",
					cycle_filters = { is_focusable, cyclefocus.filters.same_screen, cyclefocus.filters.common_tag },
					centered = true
				})
			end,
			{description = "Focus previous by history", group = "Client"}
		),
		awful.key({ modkey }, "f",
			function (c)
				c.fullscreen = not c.fullscreen
				c:raise()
			end,
			{description = "Toggle fullscreen", group = "Client"}
		),
		awful.key({ modkey, "Shift" }, "c", 
			function (c)
				c:kill()
			end,
			{description = "Close", group = "Client"}
		),
		awful.key({ altkey }, "F4",
			function (c)
				c:kill()
			end,
			{description = "Close", group = "Client"}
		),
		awful.key({ modkey, "Control" }, "space",
			awful.client.floating.toggle,
			{description = "Toggle floating", group = "Client"}
		),
		awful.key({ modkey, "Control" }, "Return",
			function (c)
				c:swap(awful.client.getmaster())
			end,
			{description = "Move to master", group = "Client"}
		),
		awful.key({ modkey }, "o",
			function (c)
				c:move_to_screen()
			end,
			{description = "Move to screen", group = "Client"}
		),
		awful.key({ modkey }, "t",
			function (c)
				c.ontop = not c.ontop
			end,
			{description = "toggle keep on top", group = "Client"}
		),
		awful.key({ modkey }, "x",
			function (c)
				c.sticky = not c.sticky
			end,
			{description = "sticky", group = "Client"}
		),
		awful.key({ modkey }, "c",
			function (c)
				c.focusable = not c.focusable
			end,
			{description = "Toggle focusable", group = "Client"}
		),
		awful.key({ modkey }, "n",
			function (c)
				c.minimized = true
			end,
			{description = "Minimize", group = "Client"}
		),
		awful.key({ modkey }, "m",
			function (c)
				local border_width = c.border_width
				c.maximized = not c.maximized
				c.border_width = border_width
				c:raise()
			end,
			{description = "(Un)Maximize", group = "Client"}
		),
		awful.key({ modkey, "Control" }, "m",
			function (c)
				c.maximized_vertical = not c.maximized_vertical
				c:raise()
			end ,
			{description = "(Un)Maximize vertically", group = "Client"}
		),
		awful.key({ modkey, "Shift" }, "m",
			function (c)
				c.maximized_horizontal = not c.maximized_horizontal
				c:raise()
			end ,
			{description = "(Un)Maximize horizontally", group = "Client"}
		),
		awful.key({ modkey }, "b",
			function (c)
				if c.border_width == 0 then
					c.border_width = dpi(beautiful.border_width, c.screen)
				else
					c.border_width = 0
				end
			end,
			{description = "Toggle border", group = "Client"}
		),
		awful.key({ modkey }, "i",
			function (c)
				awful.titlebar.toggle(c, beautiful.titlebar_position);
			end,
			{description = "Toggle title", group = "Client"}
		),
		awful.key({ modkey, "Shift" }, "t",
			function (c)
				if c.transient_to_input == nil then
					c.ontop = true
					c.sticky = true
					c.opacity = .5
					c.border_width = 0
				end

				if c.transient_to_input then
					c.transient_to_input = false
					c.focusable = true
					c.shape_input = nil
				else
					c.transient_to_input = true
					c.focusable = false
					c.shape_input = cairo.ImageSurface(cairo.Format.RGB24, 0, 0)._native
				end
			end,
			{description = "Transient client", group = "Client"}
		),

-- awful.key({ modkey, "Shift"   }, 'o',
--     function ()
--         local allclients = function (c)
--             return true
--         end
--         for c in awful.client.iterate(allclients) do
--             local ctag = awful.tag.getidx(c:tags()[1])
--             local cscreen = c.screen + 1
--             if cscreen > screen.count() then
--                 cscreen = 1
--             end
--             awful.client.movetotag(tags[cscreen][ctag], c)
--         end
--     end)

	})
end)


ruled.client.connect_signal("request::rules", function()
	-- All clients will match this rule.
	ruled.client.append_rule {
		id = "global",
		rule = { },
		properties = {
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen
		}
	}

	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule {
		id = "dialog",
		rule_any = {
			type = { "normal", "dialog" }
		},
		properties = { titlebars_enabled = true }
	}

	-- Hide titlebars for specific clients
	ruled.client.append_rule {
		id = "no-titlebars",
		rule_any = {
			class = { "URxvt", "Firefox", "firefox", "Google-chrome", "Wine", "kruler", "Alacritty" }
		},
		properties = { titlebars_enabled = false }
	}
end)

-- }}}
--

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("request::manage", function(c)
	if c.border_width then
		c.border_width = dpi(beautiful.border_width, c.screen)
	end

	if not awesome.startup then
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.centered(c, nil)
			awful.placement.no_overlap(c)
		end
		awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("property::fullscreen", function(c)
	if c.fullscreen then
		gears.timer.delayed_call(function()
			if c.valid then
				c:geometry(c.screen.geometry)
			end
		end)
	end
end)

-- Add a titlebar if titlebars are enabled

awful.titlebar.enable_tooltip = false

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
	window_buttons.close.stylesheet = 'svg { color: #f2b0b0; }'

	if beautiful.titlebar_position == "top" or beautiful.titlebar_position == "bottom" then
		layout = {
			{ -- Left
				{
					{ -- Icon
						awful.titlebar.widget.iconwidget(c),
						left = dpi(2, s),
						right = dpi(1, s),
						widget = wibox.container.margin,
						buttons = buttons,
					},
					{ text = ' ', widget = wibox.widget.textbox },
					window_buttons.floating,
					window_buttons.sticky,
					window_buttons.ontop,
					layout = wibox.layout.fixed.horizontal
				},
				top = dpi(1, s),
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
					{ text = ' ', widget = wibox.widget.textbox },
					layout = wibox.layout.fixed.horizontal()
				},
				top = dpi(1, s),
				bottom = dpi(1, s),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.align.horizontal
		}
	end
	if beautiful.titlebar_position == "left" or beautiful.titlebar_position == "right" then
		local rotate = "east"
		if beautiful.titlebar_position == "right" then
			rotate = "west"
		end

		layout = {
			{ -- Top
				{
					window_buttons.close,
					window_buttons.maximized,
					window_buttons.minimize,
					layout = wibox.layout.fixed.vertical
				},
				left = dpi(1, s),
				right = dpi(1, s),
				top = dpi(2, s),
				widget = wibox.container.margin,
			},
			{ -- Middle
				{
					{ -- Title
						halign = "center",
						widget = awful.titlebar.widget.titlewidget(c)
					},
					direction = rotate,
					widget = wibox.container.rotate
				},
				buttons = buttons,
				fill_space = true,
				layout = wibox.layout.fixed.vertical
			},
			{ -- Bottom
				{
					{ -- Icon
						awful.titlebar.widget.iconwidget(c),
						bottom = dpi(2, s),
						top = dpi(1, s),
						widget = wibox.container.margin,
						buttons = buttons,
					},
					{ { text = ' ', widget = wibox.widget.textbox }, direction = rotate, widget = wibox.container.rotate },
					window_buttons.ontop,
					window_buttons.sticky,
					window_buttons.floating,
					layout = wibox.layout.fixed.vertical
				},
				left = dpi(1, s),
				right = dpi(1, s),
				bottom = dpi(1, s),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.align.vertical
		}
	end

	local titlebar = awful.titlebar(c, {position = beautiful.titlebar_position, size = dpi(18, c.screen)})
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
	clock = function(s) return utils.calculate_text_width(s, '<span font="'..(theme.clock_font or theme.sensor_font)..'">MM  00.10  00:00</span>') end,
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

utils.volume:connect_signal('master_sink_changed', function(_, args)
	on_sink_volume_changed(args.volume, args.mute)
end)


vicious.suspend()
local function update_widgets()
	vicious.call(
		vicious_extra.network,
		function (widget, args)
			local network_current = args
			local link_quality = args.link_quality
			if link_quality ~= 0 then
				-- 75% link quality show full bar
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

			utils.battery.record(battery_current)

			for s in screen do
				for _, w in ipairs(s.battery_widget:get_children_by_id('value')) do
					if battery_current.status == "Charging" or battery_current.status == "Discharging" then
						if battery_current.power_now and battery_current.power_now > 0 then
							w:set_forced_width(widget_size.battery_extended(s))
						else
							w:set_forced_width(widget_size.battery(s))
						end
						w:set_markup(text)
					else
						w:set_forced_width(nil)
						w:set_markup(' ')
					end
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
					else
						w:set_bar_color(beautiful.fg_normal)
					end
				end
			end
		end,
		'BAT0'
	)
	update_volume()
end
-- }}}


local function attach_calendar(s)
	local clock = s.clock_widget.children[1]

	local month_calendar = awful.widget.calendar_popup.month {
		week_numbers = true,
		style_month = {
			border_width = dpi(1, s),
			border_color = theme.border_normal,
			bg_color = theme.bg_normal,
		},
		style_header = {
			border_width = 0,
			fg_color = theme.fg_accent,
			padding = dpi(5, s),
		},
		style_weeknumber = {
			border_width = 0,
			fg_color = theme.fg_secondary,
			bg_color = '#00000000',
		},
		style_weekday = {
			border_width = 0,
			fg_color = theme.fg_secondary,
			padding = dpi(5, s),
			bg_color = '#00000000',
		},
		style_normal = {
			border_width = 0,
			fg_color = theme.fg_normal,
			padding = dpi(5, s),
			bg_color = '#00000000',
		},
		style_focus = {
			border_width = dpi(1),
			fg_color = theme.fg_normal,
			padding = dpi(5, s),
			border_color = theme.border_focus,
			bg_color = theme.wibar_bg,
		}
	}
	month_calendar:attach(clock, "tr")
end



local battery_tooltip_common = {
	timeout = 5,
	timer_function = function()
		vicious.force({ widgets.battery_widget })
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
	s.tool_bar.drawin.cursor = "left_ptr"

	s.taglist_args.style = {
		squares_sel = utils.render_svg(beautiful.taglist_squares_sel, scaling, 'svg { color: '..theme.fg_normal..'; }'),
		squares_unsel = utils.render_svg(beautiful.taglist_squares_unsel, scaling, 'svg { color: '..theme.fg_normal..'; }'),
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

	s.taglist:set_base_layout(s.taglist_args.layout)
	s.tasklist:set_base_layout(s.tasklist_args.layout)
	if #s.clock_widget.children > 0 then
		s.clock_widget:remove(1)
		local clock = wibox.widget.textclock('<span font="'..(theme.clock_font or theme.sensor_font)..'">%a  %d.%m  %H:%M</span>')
		s.clock_widget:add(clock)
		attach_calendar(s)
	end

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
	s.clock_widget:set_forced_width(widget_size.clock(s))

	local border_size = dpi(beautiful.border_width, s)
	if border_size == 0 then
		border_size = 1
	end
	--for _, c in ipairs(s.clients) do
	for _, c in ipairs(client.get()) do
		if c.border_width then
			c.border_width = border_size
		end
		if has_titlebar(c) then
			c:emit_signal("request::titlebars")
		end
	end

	s.battery_tooltip:remove_from_object(s.battery_widget)
	s.battery_tooltip = awful.tooltip(battery_tooltip_common)
	s.battery_tooltip:add_to_object(s.battery_widget)
end

local function draw_wibar_background(context, cr, width, height)
	local s = context.screen
	local gradient_stops = ''
	local gradient_pos = 0.0
	if beautiful.wibar_border_top ~= nil then
		gradient_stops = gradient_stops .. ':' .. tostring(gradient_pos) .. ',' .. beautiful.wibar_border_top
		gradient_pos = gradient_pos + utils.float_dpi(1, s) / height
	end
	if beautiful.wibar_border_top ~= nil or beautiful.wibar_border_bottom ~= nil or beautiful.wibar_bg_bottom ~= nil then
		gradient_stops = gradient_stops .. ':' .. tostring(gradient_pos) .. ',' .. beautiful.wibar_bg
		if beautiful.wibar_bg_bottom ~= nil then
			gradient_pos = 1 - utils.float_dpi(1, s) / height
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


local spacer = { text = ' ', widget = wibox.widget.textbox }


screen.connect_signal("request::desktop_decoration", function(s)
	local scaling = utils.float_dpi(1, s)

	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	-- main panel
	s.tool_bar = awful.wibar({
		position = "top",
		screen = s,
		height = dpi(18, s),
		bgimage = draw_wibar_background
	})

	s.main_menu = awful.menu(get_main_menu(s))

	s.launcher = wibox.widget.imagebox(beautiful.launch)
	s.launcher.stylesheet = 'svg { color: '..theme.fg_normal..'; }'
	s.launcher:set_buttons(gears.table.join(
		awful.button({ }, 1, function() s.main_menu:toggle() end)
	))

	s.taglist_args = {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = gears.table.join(taglist_common.buttons),
		style = {
			squares_sel = utils.render_svg(beautiful.taglist_squares_sel, scaling, 'svg { color: '..theme.fg_normal..'; }'),
			squares_unsel = utils.render_svg(beautiful.taglist_squares_unsel, scaling, 'svg { color: '..theme.fg_normal..'; }'),
		},
		layout = {
			spacing = 0,
			layout  = wibox.layout.grid,
			forced_num_cols = 3,
			forced_num_rows = 3,
		},
		widget_template = {
			id = "container_role",
			widget = widgets.dpi_watcher,
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
			widget = widgets.dpi_watcher,
		},
	}
	s.tasklist = awful.widget.tasklist(s.tasklist_args)
	s.lua_prompt = awful.widget.prompt()
	s.wifi_widget = widgets.status_magnitude_widget({
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
			widget = widgets.battery_widget
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
			widget = widgets.status_magnitude_widget
		},
		{
			id = 'value',
			text = '',
			widget = wibox.widget.textbox,
			forced_width = widget_size.volume(s)
		},
		layout = wibox.layout.fixed.horizontal
	})
	s.volume_widget:set_buttons(volume_common.buttons)

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
				if dev.menu ~= nil then
					dev.menu:hide()
					dev.menu = nil
				end
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
					dev.menu = nil
					udisks_mount.mount(dev, function(path, dev, err)
						dev.menu = nil
						on_mount(path, err)
					end)
				end})
				if dev['Drive']['Ejectable'] then
					table.insert(menu, {"Eject", function()
						dev.menu = nil
						udisks_mount.unmount_and_eject(dev, function(path, dev, err)
							on_unmount(path, err)
						end)
					end})
				end
				if dev['Mounted'] then
					table.insert(menu, {"Unmount", function()
						dev.menu = nil
						udisks_mount.unmount(dev, function(path, dev, err)
							on_unmount(path, err)
						end)
					end})
				end

				if dev.menu ~= nil then
					dev.menu:hide()
					dev.menu = nil
				else
					menu = style_menu(menu, s)
					dev.menu = awful.menu(menu)
					dev.menu:show()
				end
			end)
		)
	})

	s.systray_widget = wibox.widget {
		wibox.widget.systray(),
		top = dpi(1, s),
		bottom = dpi(1, s),
		widget = wibox.container.margin,
	}

	s.clock_widget = wibox.widget({
		wibox.widget.textclock('<span font="'..(theme.clock_font or theme.sensor_font)..'">%a  %d.%m  %H:%M</span>'),
		forced_width = widget_size.clock(s),
		layout = wibox.layout.fixed.horizontal
	})
	attach_calendar(s)

	s.layoutbox_widget = widgets.layoutbox {
		screen = s,
		buttons = layoutbox_common.buttons,
	}

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
			spacer,
			s.memory_widget,
			spacer,
			s.cpu_widget,
			spacer,
			s.volume_widget,
			s.battery_widget,
			s.wifi_widget,
			s.udisks_mount,
			s.systray_widget,
			spacer,
			s.clock_widget,
			spacer,
			s.layoutbox_widget,
			layout = wibox.layout.fixed.horizontal
		},
		layout = wibox.layout.align.horizontal
	})

	update_widgets()
end)

utils.volume.start_monitor()
udisks_mount.start_monitor()


local collect_garbage = utils.debounce(function()
	collectgarbage("collect")
end, 0.5, false)


screen.connect_signal("list", function()
	collect_garbage()
end)


tag.connect_signal("request::screen", function(t)
	local new_tag

	-- find suitable tag on primary screen
	if screen.primary ~= t.screen then
		new_tag = awful.tag.find_by_name(screen.primary, t.name)
	end

	-- if primary screen is disconnecting, search another
	if new_tag == nil then
		for s in screen do
			if s ~= t.screen then
				new_tag = awful.tag.find_by_name(s, t.name)
				if new_tag ~= nil then
					break
				end
			end
		end
	end

	-- get current clients
	local clients = t:clients() or {}

	-- delete old tag and move clients to new
	t:delete(new_tag or awful.tag.find_fallback(), true)

	-- don't place clients offscreen
	gears.timer.delayed_call(function()
		for _, c in pairs(clients) do
			awful.placement.no_offscreen(c)
		end
	end)
end)


local function run_test()
	primary = screen[1]
	s = screen.fake_add(20, 20, 500, 400)
	for __, c in ipairs(primary.clients) do
		c:move_to_screen(s)
		c:move_to_tag(s.tags[2])
	end
	--for s in screen do
	--	set_screen_dpi(s, 384)
	--end
	gears.timer {
		timeout   = 0.1,
		call_now  = false,
		autostart = true,
		single_shot = true,
		callback  = function()
			--set_screen_dpi(s, 384)
			--for s in screen do
			--	set_screen_dpi(s, 192)
			--end
			s:fake_remove()
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
api:register("run_test", run_test)

local function change_dpi(force_dpi)
	local cursor_size = math.floor((force_dpi / 96)+0.5);
	if cursor_size < 1 then
		cursor_size = 1
	end
	if awesome.set_cursor_size ~= nil then
		awesome.set_cursor_size(cursor_size*24)
	end
	capi.root.cursor("left_ptr");
	for s in screen do
		set_screen_dpi(s, force_dpi)
	end
end
api:register("change_dpi", change_dpi)


awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = true
