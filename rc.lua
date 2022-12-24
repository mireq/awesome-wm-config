pcall(require, "luarocks.loader")

local gears = require("gears")
local gtable = require("gears.table")
local gdebug = require("gears.debug")
local awful = require("awful")
local vicious = require("vicious")
local vicious_extra = require("vicious_extra")
local run_shell = require("widgets.run_shell")
local popups = require("widgets.popups")
local lgi = require("lgi")
local Gio = lgi.Gio
require("awful.autofocus")

local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")
local menubar = require("menubar")
local udisks = require("widgets.udisks")
local hotkeys_popup = require("awful.hotkeys_popup")

local cairo = require('lgi').cairo
local Rsvg = require('lgi').Rsvg
local capi = {
	root = root,
	awesome = awesome,
	screen = screen
}

require("awful.hotkeys_popup.keys")

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err)
		})
		in_error = false
	end)
end


-- {{{ Utils

local function get_config_dir()
	return debug.getinfo(1).source:match("@?(.*/)")
end


local function render_svg(path, scaling)
	local svg = Rsvg.Handle.new_from_file(path)
	local dim = svg:get_dimensions()
	local img = cairo.ImageSurface(cairo.Format.ARGB32, dim.width * scaling, dim.height * scaling)
	local cr = cairo.Context(img)
	cr:scale(scaling, scaling)
	svg:render_cairo(cr)
	return img
end


local function client_menu_toggle_fn()
	local instance = nil

	return function ()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
		else
			local s = awful.screen.focused();
			instance = awful.menu.clients({
				theme = {
					width = dpi(250, s),
					height = dpi(theme.menu_height, s),
				}
			})
		end
	end
end


local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, false)
	end
end


local text_width_calculator_widget = wibox.widget.textbox()

local function calculate_text_width(s, text)
	text_width_calculator_widget:set_markup(text)
	return select(1, text_width_calculator_widget:get_preferred_size(s))
end


local function rounded_shape(size)
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, size)
	end
end


local function float_dpi(size, s)
	local ratio = s.dpi / 96
	return size * ratio
end


home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
themes = confdir .. "/themes"
active_theme = themes .. "/simple-dark"

beautiful.init(active_theme .. "/theme.lua")

--terminal = "alacrittyc"
terminal = "urxvtc"
editor = os.getenv("EDITOR")
gui_editor = "kwrite"
browser = "firefox-bin"
tasks = terminal .. " -e htop"
udisks.filemanager = "konqueror"
launch_tv = "mpv --demuxer=lavf --demuxer-lavf-format=mpegts --vf=vavpp:deint=auto:interlaced-only=yes --demuxer-lavf-o-add=fflags=+nobuffer --demuxer-lavf-probe-info=nostreams --demuxer-lavf-analyzeduration=0 --force-window=immediate http://192.168.1.111:8001/"

modkey = "Mod4"
altkey = "Mod1"

titlebar_position = "right"

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


local taglist_defaults = {}
taglist_defaults.buttons = awful.util.table.join(
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
local layoutbox_defaults = {};
layoutbox_defaults.buttons = gears.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () awful.layout.inc(-1) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

local textclock_font = theme.clock_font or theme.font;
local textclock = wibox.widget.textclock('<span font="'..textclock_font..'">%a  %d.%m  %H:%M</span>')


local volume_widget = wibox.widget.textbox()
local volume_changed = true
local volume_changed_callback = function()
	if (not volume_changed) then
		volume_changed_timer:stop();
		return
	end
	volume_changed = false
	vicious.force({volume_widget})
end
volume_changed_timer = gears.timer {
	timeout = 0.02,
	callback = volume_changed_callback
}
local volume_monitor_ctl = nil;
local function async_silent(stdout, stderr, reason, exit_code) end
local function volume(mode, widget)
	if volume_monitor_ctl == nil then
		return
	end

	if mode == "up" then
		volume_monitor_ctl:write('sink change 0.01\n')
		volume_monitor_ctl:flush()
	elseif mode == "down" then
		volume_monitor_ctl:write('sink change -0.01\n')
		volume_monitor_ctl:flush()
	elseif mode == "mute" then
		volume_monitor_ctl:write('sink mute_toggle\n')
		volume_monitor_ctl:flush()
	elseif mode == "micmute" then
		volume_monitor_ctl:write('source mute_toggle\n')
		volume_monitor_ctl:flush()
	end
end
local volumekeys = awful.util.table.join(
	awful.button({ }, 4, function () volume("up", volume_widget) end),
	awful.button({ }, 5, function () volume("down", volume_widget) end),
	awful.button({ }, 1, function () volume("mute", volume_widget) end)
)
volume_widget:buttons(volumekeys)
local volume_icon = wibox.widget.imagebox(beautiful.widget_vol_no)
volume_icon:buttons(volumekeys)
vicious.register(volume_widget, vicious_extra.volume,
	function (widget, args)
		if args.mute or args.value == 0.0 then
			volume_icon:set_image(beautiful.widget_vol_mute)
		else
			if args.value ~= nil then
				if args.value < 0.1 then
					volume_icon:set_image(beautiful.widget_vol_0)
				elseif args.value < 0.4 then
					volume_icon:set_image(beautiful.widget_vol_1)
				elseif args.value < 0.7 then
					volume_icon:set_image(beautiful.widget_vol_2)
				else
					volume_icon:set_image(beautiful.widget_vol_3)
				end
			end
		end
		if args.value == nil then
			return ''
		else
			local font = theme.volume_font or theme.font
			return '<span font="' .. font .. '">' .. math.floor(args.value * 100) .. '%</span>'
		end
	end, 15, "Master"
)

function with_line_callback_stdin(cmd, callbacks)
	local stdout_callback, stderr_callback, done_callback, exit_callback = callbacks.stdout, callbacks.stderr, callbacks.output_done, callbacks.exit
	local have_stdout, have_stderr = stdout_callback ~= nil, stderr_callback ~= nil
	local pid, _, stdin, stdout, stderr = capi.awesome.spawn(cmd, false, true, have_stdout, have_stderr, exit_callback)
	if type(pid) == "string" then
		-- Error
		return pid
	end

	local done_before = false
	local function step_done()
		if have_stdout and have_stderr and not done_before then
			done_before = true
			return
		end
		if done_callback then
			done_callback()
		end
	end
	if have_stdout then
		awful.spawn.read_lines(Gio.UnixInputStream.new(stdout, true), stdout_callback, step_done, true)
	end
	if have_stderr then
		awful.spawn.read_lines(Gio.UnixInputStream.new(stderr, true), stderr_callback, step_done, true)
	end
	if callbacks.stdin then
		callbacks.stdin(stdin, pid);
	end
	return pid
end

local volume_monitor_pid = with_line_callback_stdin('stdbuf -oL ' .. get_config_dir() .. 'pulsectrl', {
	stdout = function(line)
		local found, __, mute_flag, volume = string.find(line, "^volume sink\t[*](.)\t([0-9.]+)\t.*$")
		if found ~= nil then
			local volume_value = tonumber(volume);
			local volume_mute;
			if mute_flag == "M" then
				volume_mute = true
			else
				volume_mute = false
			end

			vicious_extra.volume.set_volume(volume_value, volume_mute);
		end
		volume_changed = true
		if (not volume_changed_timer.started) then
			volume_changed_timer:start()
		end
	end,
	exit = function()
		volume_monitor_pid = nil;
	end,
	stdin = function(stdin, pid)
		if stdin ~= nil then
			volume_monitor_ctl = io.open('/proc/' .. pid .. '/fd/0', 'w')
		end
	end,
})
awesome.connect_signal("exit", function()
	if (volume_monitor_pid) then
		awesome.kill(volume_monitor_pid, awesome.unix_signal.SIGTERM)
		volume_monitor_ctl:close();
		volume_monitor_ctl = nil;
	end
end)

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
local battery_history_file = io.open(home .. '/.battery_history', 'r')
if battery_history_file ~= nil then
	battery_history_file:close()
	battery_history_file = io.open(home .. '/.battery_history', 'a')
end
local proc_stat = io.open('/proc/stat', 'r')
local battery_icon = wibox.widget.imagebox(beautiful.widget_battery)
battery_icon.stylesheet = 'svg { fill: '..theme.fg_normal..'; }'
local battery_widget = wibox.widget.textbox()
local function battery_icon_update(s)
	if s.battery_bar then
		local a = battery_current.percentage_exact / 100
		local b = 1 - a
		local top = float_dpi(theme.widget_battery_full_bar[1] * a + theme.widget_battery_empty_bar[1] * b, s);
		local right = float_dpi(theme.widget_battery_full_bar[2] * a + theme.widget_battery_empty_bar[2] * b, s);
		local bottom = float_dpi(theme.widget_battery_full_bar[3] * a + theme.widget_battery_empty_bar[3] * b, s);
		local left = float_dpi(theme.widget_battery_full_bar[4] * a + theme.widget_battery_empty_bar[4] * b, s);
		s.battery_bar:set_top(top)
		s.battery_bar:set_right(right)
		s.battery_bar:set_bottom(bottom)
		s.battery_bar:set_left(left)
		if battery_current.status == "Charging" then
			s.battery_bar_fill:set_bg("#63b5f6")
			battery_icon.stylesheet = 'svg { fill: '..theme.fg_normal..'; }'
		elseif battery_current.status == "Discharging" then
			if battery_current.percentage_exact < 30 then
				s.battery_bar_fill:set_bg("#e33a35")
				battery_icon.stylesheet = 'svg { fill: #d78382; }'
			else
				s.battery_bar_fill:set_bg("#4cb050")
				battery_icon.stylesheet = 'svg { fill: '..theme.fg_normal..'; }'
			end
			if battery_current.percentage_exact < 5 then
				naughty.notify({
					text = "Battery empty.",
					title = "Battery empty!",
					position = "top_right",
					timeout = 1,
					fg="#000000",
					bg="#ffffff",
					screen = 1,
					ontop = true,
				})
			elseif battery_current.percentage_exact < 10 then
				naughty.notify({
					text = "Battery status low.",
					title = "Battery low",
					position = "top_right",
					timeout = 1,
					fg="#ffffff",
					bg="#262729",
					screen = 1,
					ontop = true,
				})
			end
		else
			s.battery_bar_fill:set_bg(theme.fg_normal)
		end
	end
end
vicious.register(battery_widget, vicious_extra.bat,
	function (widget, args)
		battery_current = args

		if args.percentage ~= nil then
			awful.screen.connect_for_each_screen(function(s)
				battery_icon_update(s)
				if s.battery_text_container then
					if args.power_now and args.power_now > 0 then
						s.battery_text_container:set_forced_width(s.battery_width_ext)
					else
						s.battery_text_container:set_forced_width(s.battery_width)
					end
				end
			end)
		end

		if args.percentage == nil then
			return ''
		end

		local text = '<span font="'..(theme.battery_percent_font or theme.font)..'">'..args.percentage..' %</span>'
		if args.power_now and args.power_now > 0 then
			text = text .. ' <span font="'..(theme.battery_current_font or theme.font)..'" alpha="50%">'..string.format("%.1f", args.power_now)..' W</span>'
		end

		if battery_history_file ~= nil and proc_stat ~= nil then
			proc_stat:seek("set", 0)
			local cpuline = '';
			for line in proc_stat:lines() do
				local _, _, cpu, user, nice, system, idle, iowait, irq, softirq = string.find(line, "^cpu([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)")
				if cpu ~= nil then
					if cpu ~= '0' then
						cpuline = cpuline .. ' '
					end
					cpuline = cpuline .. user .. ',' .. nice .. ',' .. system .. ',' .. idle .. ',' .. iowait .. ',' .. irq .. ',' .. softirq
				end
			end

			if cpuline then
				cpuline = ';' .. cpuline
			end

			local time = os.time()
			local status = nil
			if battery_current.status == "Charging" then
				status = 'c'
			elseif battery_current.status == "Discharging" then
				status = 'd'
			end
			if status then
				battery_history_file:write(status .. ";" .. time .. ";" .. math.floor(args.power_now * 1000000) .. ";" .. math.floor(args.energy_now * 1000000) .. ";" .. math.floor(args.voltage_now * 1000000) .. cpuline .. "\n")
				battery_history_file:flush()
			end
		end

		return text
	end, 15, 'BAT0'
)


local battery_tooltip = awful.tooltip {
	objects = {battery_icon, battery_widget},
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


local cpu_icon = wibox.widget.imagebox(beautiful.widget_cpu)
cpu_icon.stylesheet = 'svg { fill: '..theme.fg_normal..'; }'

local cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu,
	function(widget, args)
		if args[1] > 10 then
			cpu_icon.stylesheet = 'svg { fill: #d78382; }'
		else
			cpu_icon.stylesheet = 'svg { fill: '..theme.fg_normal..'; }'
		end
		return '<span font="'..(theme.cpu_percent_font or theme.font)..'">' .. string.format("%2d", args[1]) .. " %</span>"
	end,
3)
cpu_icon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.spawn(tasks, false) end)))
popups.htop(cpu_widget, {
	title_color = "#ffffff",
	user_color = "#00ff00",
	root_color = "#ffff00",
	terminal = "urxvt"
})


local mem_icon = wibox.widget.imagebox(beautiful.widget_mem)
mem_icon.stylesheet = 'svg { fill: '..theme.fg_normal..'; }'
local mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem,
	function(widget, args)
		return '<span font="'..(theme.cpu_percent_font or theme.font)..'">' .. string.format("%4d", args[2]) .. " MB</span>"
	end,
3)

local temp_icon = wibox.widget.imagebox(beautiful.widget_temp)
temp_icon.stylesheet = 'svg { fill: '..theme.fg_normal..'; }'
local temp_widget = wibox.widget.textbox()
vicious.register(temp_widget, vicious.widgets.thermal,
	function(widget, args)
		if args[1] > 60 then
			temp_icon.stylesheet = 'svg { fill: #d78382; }'
		else
			temp_icon.stylesheet = 'svg { fill: '..theme.fg_normal..'; }'
		end
		return '<span font="'..(theme.temp_font or theme.font)..'">' .. args[1] .. ' °C</span>'
	end,
10, {"thermal_zone0", "sys"})


local network_current = {
	link_quality = 0.0
}


local wireless_icon = wibox.widget.imagebox(beautiful.widget_net_wireless)
wireless_icon.stylesheet = 'path { fill: '..theme.fg_normal..'; }'
popups.netstat(wireless_icon, {
	title_color = "#ffffff",
	established_color = "#ffff00",
	listen_color = "#00ff00"
})
local function wireless_chart_shape(value)
	local function shape(cr, width, height)
		local angle = (theme.widget_wireless_chart[1] / 180 / 2) * math.pi
		local size = dpi(theme.widget_wireless_chart[2], s) * value
		local trans_x = (width - (size * 2)) / 2;
		local trans_y = dpi(theme.widget_wireless_chart[3], s) + dpi((1.0 - value) * theme.widget_wireless_chart[2], s)
		gears.shape.transform(gears.shape.arc): translate(trans_x, trans_y) (cr, size*2, size*2, size, -angle - math.pi / 2, angle - math.pi / 2)
	end
	return shape
end
vicious.register(wireless_icon, vicious_extra.network,
	function (widget, args)
		network_current = args
		awful.screen.connect_for_each_screen(function(s)
			if s.wireless_chart ~= nil then
				s.wireless_chart:set_shape(wireless_chart_shape(math.min(network_current.link_quality * 1.25, 1.0)))
			end
		end)
	end
)


-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local mymainmenu = nil

function set_screen_dpi(s)
	local scaling = float_dpi(1, s)
	local menu = s.main_menu;
	menu.theme.width = theme.menu_width * scaling;
	menu.theme.height = theme.menu_height * scaling;

	for _, item in ipairs(menu.items) do
		item.height = menu.theme.height
		item.width = menu.theme.width
		item.widget:get_first():get_children()[1]:set_left(item.height + dpi(2, s))
	end
	for _, child in pairs(menu.child) do
		for _, item in ipairs(child.items) do
			item.height = menu.theme.height
			item.width = menu.theme.width
			item.widget:get_first():get_children()[1]:set_left(item.height + dpi(2, s))
		end
	end

	s.launcher:set_image(render_svg(theme.launch, scaling))

	local textclock_width = calculate_text_width(s, '<span font="'..textclock_font..'">MM  00.10  00:00</span>')
	local volume_width = calculate_text_width(s, '<span font="'..(theme.volume_font or theme.font)..'">100 %</span>')
	s.battery_width = calculate_text_width(s, '<span font="'..(theme.battery_percent_font or theme.font)..'">100 %</span>')
	s.battery_width_ext = calculate_text_width(s, '<span font="'..(theme.battery_percent_font or theme.font)..'">100 %</span> <span font="'..(theme.battery_current_font or theme.font)..'">99.9 W</span>')
	local cpu_width = calculate_text_width(s, '<span font="'..(theme.cpu_percent_font or theme.font)..'">100 %</span>')
	local memory_width = calculate_text_width(s, '<span font="'..(theme.mem_percent_font or theme.font)..'">99999 MB</span>')
	local temp_width = calculate_text_width(s, '<span font="'..(theme.temp_font or theme.font)..'">100 %</span>')

	s.textclock.forced_width = textclock_width
	s.volume_widget.forced_width = volume_width
	s.cpu_widget.forced_width = cpu_width
	s.memory_widget.forced_width = memory_width
	s.temp_widget.forced_width = temp_width

	s.taglist_args.widget_template.forced_width = dpi(6, s)
	s.taglist_args.widget_template.forced_height = dpi(6, s)

	for _, c in ipairs(s.taglist:get_children()) do
		c.widget.top = s.taglist_args.widget_template.forced_height
		c:set_forced_width(s.taglist_args.widget_template.forced_height)
		c:set_forced_height(s.taglist_args.widget_template.forced_width)
	end
end


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
	{ "hotkeys", function() return false, hotkeys_popup.show_help end},
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
local main_menu = awful.menu({
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
		height = theme.menu_height,
		width = theme.menu_width,
		submenu_icon = render_svg(theme.menu_submenu_icon, 1)
	}
})


--awesome.set_cursor_size(48);
local function setup_screen(s)
	set_wallpaper(s)

	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	local scaling = float_dpi(1, s)
	local spr = wibox.widget.textbox('   ')
	mymainmenu = main_menu
	s.main_menu = main_menu

	local launcher = awful.widget.launcher({
		image = beautiful.launch,
		menu = main_menu,
	})
	s.launcher = launcher

	s.taglist_args = {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_defaults.buttons,
		buttons = taglist_defaults.buttons,
		style = {
			squares_sel = render_svg(theme.taglist_squares_sel, scaling),
			squares_unsel = render_svg(theme.taglist_squares_unsel, scaling),
		},
		layout = {
			spacing = 0,
			layout  = wibox.layout.grid,
			forced_num_cols = 3,
			forced_num_rows = 3,
		},
		widget_template = {
			id = "background_role",
			widget = wibox.container.background,
			forced_width = dpi(6, s),
			forced_height = dpi(6, s),
			{
				{
					id = "text_role",
					widget = wibox.widget.textbox,
				},
				{
					id = "icon_role",
					widget = wibox.widget.imagebox,
				},
				top = dpi(6, s),
				widget = wibox.container.margin,
			}
		}
	}
	s.taglist = awful.widget.taglist(s.taglist_args)

	s.tasklist = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_defaults.buttons,
		widget_template = {
			{
				{
					{
						{
							id = 'icon_role',
							widget = wibox.widget.imagebox,
						},
						top = dpi(1, s),
						bottom = dpi(1, s),
						left = dpi(4, s),
						widget = wibox.container.margin,
					},
					{
						{
							id = 'text_role',
							widget = wibox.widget.textbox,
						},
						left = dpi(4, s),
						widget = wibox.container.margin,
					},
					layout = wibox.layout.fixed.horizontal,
				},
				{
					id = "background_role",
					widget = wibox.container.background,
					forced_height = dpi(1, s),
				},
				layout = wibox.layout.stack,
			},
			widget = wibox.container.margin,
			--{
			--	widget = wibox.container.background,
			--	forced_height = dpi(2, s),
			--	bg = '#00000000'
			--},
			--{
			--	{
			--		{
			--			{
			--				id = 'icon_role',
			--				widget = wibox.widget.imagebox,
			--			},
			--			top = dpi(-1, s),
			--			bottom = dpi(-1, s),
			--			right = dpi(4, s),
			--			widget = wibox.container.margin,
			--		},
			--		layout = wibox.layout.fixed.horizontal,
			--	},
			--	left = dpi(4, s),
			--	right = dpi(4, s),
			--	widget = wibox.container.margin,
			--	forced_height = dpi(14, s),
			--},
			--{
			--	id = "background_role",
			--	widget = wibox.container.background,
			--	forced_height = dpi(2, s),
			--},
			--widget = wibox.layout.fixed.vertical,
		}
	}

	if (theme.str_layout_floating == nil) then
		theme.str_layout_tile = theme.layout_tile
		theme.str_layout_tileleft = theme.layout_tileleft
		theme.str_layout_tilebottom = theme.layout_tilebottom
		theme.str_layout_tiletop = theme.layout_tiletop
		theme.str_layout_fairv = theme.layout_fairv
		theme.str_layout_fairh = theme.layout_fairh
		theme.str_layout_spiral = theme.layout_spiral
		theme.str_layout_dwindle = theme.layout_dwindle
		theme.str_layout_max = theme.layout_max
		theme.str_layout_fullscreen = theme.layout_fullscreen
		theme.str_layout_magnifier = theme.layout_magnifier
		theme.str_layout_floating = theme.layout_floating
	end

	theme.layout_floating = render_svg(theme.str_layout_floating, scaling)
	theme.layout_tile = render_svg(theme.str_layout_tile, scaling)
	theme.layout_tileleft = render_svg(theme.str_layout_tileleft, scaling)
	theme.layout_tilebottom = render_svg(theme.str_layout_tilebottom, scaling)
	theme.layout_tiletop = render_svg(theme.str_layout_tiletop, scaling)
	theme.layout_fairv = render_svg(theme.str_layout_fairv, scaling)
	theme.layout_fairh = render_svg(theme.str_layout_fairh, scaling)
	theme.layout_spiral = render_svg(theme.str_layout_spiral, scaling)
	theme.layout_dwindle = render_svg(theme.str_layout_dwindle, scaling)
	theme.layout_max = render_svg(theme.str_layout_max, scaling)
	theme.layout_fullscreen = render_svg(theme.str_layout_fullscreen, scaling)
	theme.layout_magnifier = render_svg(theme.str_layout_magnifier, scaling)
	theme.layout_floating = render_svg(theme.str_layout_floating, scaling)

	s.promptbox = awful.widget.prompt()
	s.layoutbox = awful.widget.layoutbox {
		screen = s,
	}
	s.layoutbox:buttons(layoutbox_defaults.buttons)

	local month_calendar = awful.widget.calendar_popup.month {
		week_numbers = true,
		style_month = {
			border_width = dpi(1),
			border_color = theme.border_normal,
			bg_color = theme.bg_normal,
			shape = rounded_shape(5),
		},
		style_header = {
			border_width = 0,
			fg_color = theme.fg_accent,
			padding = dpi(5),
		},
		style_weeknumber = {
			border_width = 0,
			fg_color = theme.fg_secondary,
			bg_color = '#00000000',
		},
		style_weekday = {
			border_width = 0,
			fg_color = theme.fg_secondary,
			padding = dpi(5),
			bg_color = '#00000000',
		},
		style_normal = {
			border_width = 0,
			fg_color = theme.fg_normal,
			padding = dpi(5),
			bg_color = '#00000000',
		},
		style_focus = {
			border_width = dpi(1),
			fg_color = theme.fg_normal,
			padding = dpi(5),
			border_color = theme.border_focus,
			shape = rounded_shape(3),
			bg_color = theme.wibar_bg,
		}
	}
	month_calendar:attach(textclock, "tr")

	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(launcher)
	left_layout:add(s.taglist)
	left_layout:add(s.promptbox)
	local right_layout = wibox.layout.fixed.horizontal()
	s.wireless_chart = wibox.widget {
		bg = theme.fg_normal,
		widget = wibox.container.background,
	}
	s.wireless_chart:set_shape(wireless_chart_shape(0))

	right_layout:add(wibox.widget {
		wireless_icon,
		s.wireless_chart,
		layout = wibox.layout.stack,
	})
	right_layout:add(spr)
	right_layout:add(temp_icon)
	s.temp_widget = wibox.widget {
		widget = temp_widget,
		align = "left"
	}
	right_layout:add(s.temp_widget)
	right_layout:add(spr)
	right_layout:add(mem_icon)
	s.memory_widget = wibox.widget {
		widget = mem_widget,
		align = "left"
	}
	right_layout:add(s.memory_widget)
	right_layout:add(spr)
	right_layout:add(cpu_icon)
	s.cpu_widget = wibox.widget {
		widget = cpu_widget,
		align = "left"
	}
	right_layout:add(s.cpu_widget)
	right_layout:add(spr)
	s.battery_bar_fill = wibox.widget {
		bg = '#cccdcf',
		widget = wibox.container.background,
	}
	s.battery_bar = wibox.widget {
		s.battery_bar_fill,
		top = dpi(theme.widget_battery_full_bar[1], s),
		right = dpi(theme.widget_battery_full_bar[2], s),
		bottom = dpi(theme.widget_battery_full_bar[3], s),
		left = dpi(theme.widget_battery_full_bar[4], s),
		forced_width = 1,
		widget = wibox.container.margin,
	}
	right_layout:add(wibox.widget {
		battery_icon,
		s.battery_bar,
		layout = wibox.layout.stack,
		widget = wibox.container.margin,
	})
	s.battery_text_container = wibox.widget {
		widget = battery_widget,
		forced_width = s.battery_width_ext,
		align = "left"
	}
	right_layout:add(s.battery_text_container)
	right_layout:add(spr)
	right_layout:add(volume_icon)
	s.volume_widget = wibox.widget {
		widget = volume_widget,
		align = "left"
	}
	right_layout:add(s.volume_widget)
	right_layout:add(spr)
	local systray_separator = wibox.widget {
		spr,
		layout = awful.widget.only_on_screen,
		screen = "primary",
	}
	systray_separator.visible = false
	local systray_widget = wibox.widget.systray()
	systray_widget:connect_signal("widget::layout_changed", function(e)
		local num_entries = capi.awesome.systray()
		systray_separator.visible = num_entries > 0
	end)
	right_layout:add(wibox.widget {
		{
			top = dpi(1, s),
			bottom = dpi(1, s),
			widget = wibox.container.margin,
			systray_widget
		},
		layout = awful.widget.only_on_screen,
		screen = "primary",
	})
	right_layout:add(systray_separator)
	right_layout:add(wibox.widget {
		layout = awful.widget.only_on_screen,
		screen = "primary",
		udisks.widget
	})
	s.textclock = wibox.widget {
		widget = textclock,
		--forced_width = textclock_width,
		align = "center"
	}
	right_layout:add(s.textclock)
	right_layout:add(spr)
	right_layout:add(s.layoutbox)

	set_screen_dpi(s);

	s.tool_bar = awful.wibar({
		position = "top",
		screen = s,
		height = dpi(18, s),
		bg = beautiful.wibar_bg or beaaauiful.bg_normal
	})
	s.tool_bar:setup {
		layout = wibox.layout.align.horizontal,
		left_layout,
		s.tasklist,
		right_layout
	}

	battery_icon_update(s)
end

awful.screen.connect_for_each_screen(setup_screen)


vicious.suspend()
local update_timer = gears.timer({ timeout = 10 })
update_timer:connect_signal("timeout", function()
	vicious.force({ textclock, battery_widget, cpu_widget, mem_widget, temp_widget, wireless_icon })
end)
update_timer:start()
vicious.force({ textclock, battery_widget, cpu_widget, mem_widget, temp_widget, wireless_icon })


volume_changed_callback()



local clientbuttons = gears.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	--awful.button({ altkey }, 1, awful.mouse.client.move),
	awful.button({ altkey }, 1, function(c)
		if c.fullscreen or c.maximized then
			c.fullscreen = false
			c.maximized = false
			c.width = c.screen.geometry.width
			c.height = c.screen.geometry.height
		end
		c:activate { context = "mouse_click", action = "mouse_move" }
	end),
	awful.button({ altkey }, 3, function(c)
		if c.fullscreen or c.maximized then
			c.fullscreen = false
			c.maximized = false
			c.width = c.screen.geometry.width
			c.height = c.screen.geometry.height
		end
		c:activate { context = "mouse_click", action = "mouse_resize" }
	end))
	--awful.button({ altkey }, 3, awful.mouse.client.resize))


-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey,           }, "s",
		hotkeys_popup.show_help,
		{description="show help", group="awesome"}),
	awful.key({ modkey,           }, "Left",
		awful.tag.viewprev,
		{description = "view previous", group = "tag"}),
	awful.key({ modkey,           }, "Right",
		awful.tag.viewnext,
		{description = "view next", group = "tag"}),
	awful.key({ modkey,           }, "Escape",
		awful.tag.history.restore,
		{description = "go back", group = "tag"}),
	awful.key({ modkey,           }, "Tab",
		awful.tag.history.restore,
		{description = "go back", group = "tag"}),
	awful.key({ modkey,           }, "j",
		function ()
			awful.client.focus.byidx( 1)
		end,
		{description = "focus next by index", group = "client"}
	),
	awful.key({ modkey,           }, "k",
		function ()
			awful.client.focus.byidx(-1)
		end,
		{description = "focus previous by index", group = "client"}
	),
	awful.key({ modkey,           }, "w",
		function () mymainmenu:show() end,
		 {description = "show main menu", group = "awesome"}),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   }, "j",
		function ()
			awful.client.swap.byidx(1)
		end,
		{description = "swap with next client by index", group = "client"}),
	awful.key({ modkey, "Shift"   }, "k",
		function ()
			awful.client.swap.byidx( -1)
		end,
		{description = "swap with previous client by index", group = "client"}),
	awful.key({ modkey, "Control" }, "j",
		function ()
			awful.screen.focus_relative(1)
		end,
		{description = "focus the next screen", group = "screen"}),
	awful.key({ modkey, "Control" }, "k",
		function ()
			awful.screen.focus_relative(-1)
		end,
		{description = "focus the previous screen", group = "screen"}),
	awful.key({ modkey,           }, "u",
		awful.client.urgent.jumpto,
		{description = "jump to urgent client", group = "client"}),
	awful.key({ altkey,           }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end,
		{description = "go back", group = "client"}),

	-- Standard program
	awful.key({ modkey,           }, "Return",
		function ()
			awful.spawn(terminal)
		end,
		{description = "open a terminal", group = "launcher"}),
	awful.key({ modkey, "Control" }, "F7",
		function ()
			awful.spawn("/etc/acpi/actions/switchvideo.sh")
		end,
		{description = "switch video", group = "launcher"}),
	awful.key({modkey, "Control", "Shift" }, "r",
		awesome.restart,
		{description = "reload awesome", group = "awesome"}),
	awful.key({ modkey, "Shift"   }, "q",
		awesome.quit,
		{description = "quit awesome", group = "awesome"}),

	awful.key({ modkey,           }, "l",
		function ()
			awful.tag.incmwfact( 0.05)
		end,
		{description = "increase master width factor", group = "layout"}),
	awful.key({ modkey,           }, "h",
		function ()
			awful.tag.incmwfact(-0.05)
		end,
		{description = "decrease master width factor", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "h",
		function ()
			awful.tag.incnmaster(1, nil, true)
		end,
		{description = "increase the number of master clients", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "l",
		function ()
			awful.tag.incnmaster(-1, nil, true)
		end,
		{description = "decrease the number of master clients", group = "layout"}),
	awful.key({ modkey, "Control" }, "h",
		function ()
			awful.tag.incncol(1, nil, true)
		end,
		{description = "increase the number of columns", group = "layout"}),
	awful.key({ modkey, "Control" }, "l",
		function ()
			awful.tag.incncol(-1, nil, true)
		end,
		{description = "decrease the number of columns", group = "layout"}),
	awful.key({ modkey,           }, "space",
		function ()
			awful.layout.inc(1)
		end,
		{description = "select next", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "space",
		function ()
			awful.layout.inc(-1)
		end,
		{description = "select previous", group = "layout"}),

	awful.key({ modkey, "Control" }, "n",
		function ()
			local c = awful.client.restore()
			-- Focus restored client
			if c then
				client.focus = c
				c:raise()
			end
		end,
		{description = "restore minimized", group = "client"}),

	awful.key({modkey}, "r",
		function ()
			run_shell.launch()
		end,
		{description = "run shell", group = "awesome"}),

	awful.key({ modkey }, "a",
		function ()
			awful.prompt.run {
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().promptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval"
		}
		end,
		{description = "lua execute prompt", group = "awesome"}),
	-- Menubar
	awful.key({ modkey }, "p",
		function()
			menubar.show()
		end,
		{description = "show the menubar", group = "launcher"}),
	awful.key({ modkey, altkey, "Shift"   }, "r",
		function ()
			awful.spawn("/usr/local/bin/record_desktop_toggle")
		end,
		{description = "record desktop", group = "launcher"}),

	--awful.key({ modkey }, "v",
	--	function()
	--		keygrabber.run(function(mod, key, event)
	--			if event == "release" then return end
	--			keygrabber.stop();
	--			if key == 'w' then
	--				awful.spawn.with_shell('sleep 0.1; sh -c \'xdotool type "`generate.py w`"\'');
	--			elseif key == 'W' then
	--				awful.spawn.with_shell('sleep 0.1; sh -c \'xdotool type "`generate.py uw`"\'');
	--			elseif key == 'p' then
	--				awful.spawn.with_shell('sleep 0.1; sh -c \'xdotool type "`generate.py p 4`"\'');
	--			elseif key == 's' then
	--				awful.spawn.with_shell('sleep 0.1; sh -c \'xdotool type "`generate.py s`"\'');
	--			end
	--		end)
	--	end
	--),

	-- Volume controls
	awful.key({ }, "XF86AudioRaiseVolume", function () volume("up", volume_widget) end),
	awful.key({ }, "XF86AudioLowerVolume", function () volume("down", volume_widget) end),
	awful.key({ }, "XF86AudioMute", function () volume("mute", volume_widget) end),
	awful.key({ }, "XF86AudioMicMute", function () volume("micmute", volume_widget) end)
	--awful.key({ modkey, "Shift"   }, "d",
	--	function ()
	--		awesome.set_cursor_size(48);
	--		capi.root.cursor("right_ptr");
	--		for s in screen do
	--			s.tool_bar.drawin.cursor = "right_ptr";
	--		end
	--	end,
	--	{description = "test change dpi", group = "launcher"})
)



beautiful.change_dpi = function(force_dpi)
	local cursor_size = math.floor((force_dpi / 96)+0.5);
	if cursor_size < 1 then
		cursor_size = 1
	end
	if awesome.set_cursor_size ~= nil then
		awesome.set_cursor_size(cursor_size*24)
	end
	capi.root.cursor("left_ptr");

	for s in screen do
		local scaling = float_dpi(1, s)
		s.dpi = force_dpi
		s.tool_bar.height = dpi(18, s);
		s.tool_bar.drawin.cursor = "left_ptr";
		set_screen_dpi(s)
	end

	beautiful.xresources.set_dpi(force_dpi)
	for _, c in ipairs(client.get()) do
		if c.border_width then
			c.border_width = dpi(beautiful.border_width, c.screen)
		end
		c:emit_signal("request::titlebars")
	end
	vicious.force({ textclock, battery_widget, cpu_widget, mem_widget, temp_widget, wireless_icon })
end

clientkeys = gears.table.join(
	awful.key({ modkey,           }, "f",
		function (c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{description = "toggle fullscreen", group = "client"}),
	awful.key({ modkey, "Shift"   }, "c", 
		function (c)
			c:kill()
		end,
		{description = "close", group = "client"}),
	awful.key({ altkey,           }, "F4",
		function (c)
			c:kill()
		end,
		{description = "close", group = "client"}),
	awful.key({ modkey, "Control" }, "space",
		awful.client.floating.toggle,
		{description = "toggle floating", group = "client"}),
	awful.key({ modkey, "Control" }, "Return",
		function (c)
			c:swap(awful.client.getmaster())
		end,
		{description = "move to master", group = "client"}),
	awful.key({ modkey,           }, "o",
		function (c)
			c:move_to_screen()
		end,
		{description = "move to screen", group = "client"}),
	awful.key({ modkey,           }, "t",
		function (c)
			c.ontop = not c.ontop
		end,
		{description = "toggle keep on top", group = "client"}),
	awful.key({ modkey,           }, "x",
		function (c)
			c.sticky = not c.sticky
		end,
		{description = "sticky", group = "client"}),
	awful.key({ modkey,           }, "c",
		function (c)
			c.focusable = not c.focusable
		end,
		{description = "toggle focusable", group = "client"}),
	awful.key({ modkey,           }, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end,
		{description = "minimize", group = "client"}),
	awful.key({ modkey,           }, "m",
		function (c)
			local border_width = c.border_width
			c.maximized = not c.maximized
			c.border_width = border_width
			c:raise()
		end,
		{description = "(un)maximize", group = "client"}),
	awful.key({ modkey, "Control" }, "m",
		function (c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end ,
		{description = "(un)maximize vertically", group = "client"}),
	awful.key({ modkey, "Shift"   }, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end ,
		{description = "(un)maximize horizontally", group = "client"}),
	awful.key({ modkey,           }, "b",
		function (c)
			if c.border_width == 0 then
				c.border_width = 1
			else
				c.border_width = 0
			end
		end,
		{description = "toggle border", group = "client"}),
	awful.key({ modkey,           }, "i",
		function (c)
			awful.titlebar.toggle(c, titlebar_position);
		end,
		{description = "toggle title", group = "client"}),

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
		{description = "transient client", group = "client"})

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
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
			function ()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end,
			{description = "view tag #"..i, group = "tag"}),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9,
			function ()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end,
			{description = "toggle tag #" .. i, group = "tag"}),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end,
			{description = "move focused client to tag #"..i, group = "tag"}),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
			function ()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end,
			{description = "toggle focused client on tag #" .. i, group = "tag"})
	)
end

root.keys(globalkeys)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).

awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = { },
		properties = {
			--border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen
		}
	},
	--{ rule = { class = "Firefox" },
	--	properties = { tag = "2" } },
	-- Floating clients.
	{
		rule_any = {
			instance = {
				"copyq",
			},
			class = {
				"Kruler",
				"gimp",
				"Wpa_gui",
				"pinentry",
				"Yakuake",
			},
			name = {
				"Event Tester",  -- xev.
			},
			role = {
				"AlarmWindow",  -- Thunderbird's calendar.
				"pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = { floating = true }
	},

	-- Add titlebars to normal clients and dialogs
	{
		rule_any = {
			type = { "normal", "dialog" }
		},
		properties = { titlebars_enabled = true }
	},
}

-- }}}
--

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end
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

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	local secondary_layout, primary_layout, title_layout, layout = nil;
	if titlebar_position == "top" or titlebar_position == "bottom" then
		-- Secondary widgets (left or bottom)
		secondary_layout = wibox.layout.fixed.horizontal()
		secondary_layout:add(awful.titlebar.widget.floatingbutton(c))
		secondary_layout:add(awful.titlebar.widget.stickybutton(c))
		secondary_layout:add(awful.titlebar.widget.ontopbutton(c))
		secondary_layout:add(awful.titlebar.widget.iconwidget(c))

		-- Primary widgets (top right)
		primary_layout = wibox.layout.fixed.horizontal()
		primary_layout:add(awful.titlebar.widget.minimizebutton(c))
		primary_layout:add(awful.titlebar.widget.maximizedbutton(c))
		primary_layout:add(awful.titlebar.widget.closebutton(c))

		-- The title goes in the middle
		local title = awful.titlebar.widget.titlewidget(c)
		title_layout = wibox.layout.align.horizontal()
		title_layout:set_middle(title);
		title_layout:set_expand("outside")

		-- Now bring it all together
		layout = wibox.layout.align.horizontal()
		layout:set_left(secondary_layout)
		layout:set_right(primary_layout)
		layout:set_middle(title_layout)
	else
		-- Secondary widgets (left or bottom)
		secondary_layout = wibox.layout.fixed.vertical()
		secondary_layout:add({
			awful.titlebar.widget.iconwidget(c),
			top = dpi(1, s),
			bottom = dpi(1, s),
			left = dpi(1, s),
			right = dpi(1, s),
			widget = wibox.container.margin,
		})
		secondary_layout:add(awful.titlebar.widget.stickybutton(c))
		secondary_layout:add(awful.titlebar.widget.ontopbutton(c))
		secondary_layout:add(awful.titlebar.widget.floatingbutton(c))

		-- Primary widgets (top right)
		primary_layout = wibox.layout.fixed.vertical()
		primary_layout:add(awful.titlebar.widget.closebutton(c))
		primary_layout:add(awful.titlebar.widget.maximizedbutton(c))
		primary_layout:add(awful.titlebar.widget.minimizebutton(c))

		-- The title goes in the middle
		local title = awful.titlebar.widget.titlewidget(c)
		title_layout = wibox.layout.align.horizontal()
		title_layout:set_middle(title);
		title_layout:set_expand("outside")

		-- Now bring it all together
		layout = wibox.layout.align.vertical()
		layout:set_top(primary_layout)
		layout:set_bottom(secondary_layout)
		local rotate = "east"
		if titlebar_position == "right" then
			rotate = "west"
		end
		layout:set_middle(wibox.container.rotate(title_layout, rotate))
	end

	-- buttons for the titlebar
	title_layout:buttons(gears.table.join(
			awful.button({ }, 1, function()
				client.focus = c
				c:raise()
				c:activate { context = "titlebar", action = "mouse_move" }
			end),
			awful.button({ }, 3, function()
				client.focus = c
				c:raise()
				c:activate { context = "titlebar", action = "mouse_resize" }
			end)
		)
	)

	awful.titlebar(c, {position = titlebar_position, size = dpi(18, c.screen)}):set_widget(layout)

	if c.class == 'URxvt' or c.class == 'Firefox' or c.class == 'firefox' or c.class == 'Google-chrome' or c.class == "Wine" or c.class == "kruler" or c.class == "Alacritty" then
		awful.titlebar.hide(c, titlebar_position);
	end
end)

--tag.connect_signal("request::screen",
--	function(t)
--		local fallback_tag = nil
--
--		-- find tag with same name on any other screen
--		for other_screen in screen do
--			if other_screen ~= t.screen then
--				fallback_tag = awful.tag.find_by_name(other_screen, t.name)
--				if fallback_tag ~= nil then
--					break
--				end
--			end
--		end
--
--		-- no tag with same name exists, chose random one
--		if fallback_tag == nil then
--			fallback_tag = awful.tag.find_fallback()
--		end
--
--		-- delete the tag and move it to other screen
--		t:delete(fallback_tag, true)
--	end
--)

--tag.connect_signal("request::screen", function(t)
--	for s in screen do
--		if s ~= nil and
--			t.screen ~= nil and
--			s ~= t.screen and
--			s.geometry.x == t.screen.geometry.x and
--			s.geometry.y == t.screen.geometry.y and
--			s.geometry.width == t.screen.geometry.width and
--			s.geometry.height == t.screen.geometry.height
--		then
--			local t2 = awful.tag.find_by_name(s, t.name)
--			if t2 then
--				t:swap(t2)
--			else
--				t.screen = s
--			end
--			return
--		end
--	end
--end)

local tag_store = {}
tag.connect_signal("request::screen", function(t)
	local fallback_tag = nil

	-- find tag with same name on any other screen
	for other_screen in screen do
		if other_screen ~= t.screen then
			fallback_tag = awful.tag.find_by_name(other_screen, t.name)
			if fallback_tag ~= nil then
				break
			end
		end
	end

	-- no tag with same name exists, chose random one
	if fallback_tag == nil then
		fallback_tag = awful.tag.find_fallback()
	end

	if not (fallback_tag == nil) then
		local output = next(t.screen.outputs)

		if tag_store[output] == nil then
			tag_store[output] = {}
		end

		clients = t:clients()
		tag_store[output][t.name] = clients

		for _, c in ipairs(clients) do
			c:move_to_tag(fallback_tag)
		end
	end
end)

screen.connect_signal("added", function(s)
	local output = next(s.outputs)
	naughty.notify({ text = output .. " Connected" })

	tags = tag_store[output]
	if not (tags == nil) then
		naughty.notify({ text = "Restoring Tags" })

		for _, tag in ipairs(s.tags) do
			clients = tags[tag.name]
			if not (clients == nil) then
				for _, client in ipairs(clients) do
					client:move_to_tag(tag)
				end
			end
		end
	end
end)

screen.connect_signal("list", function()
	local clients = {}
	--local main_screen = nil
	for s in screen do
		--if main_screen == nil then
		--	main_screen = s
		--end
		for dummy, c in ipairs(s.all_clients) do
			table.insert(clients, c)
		end
	end

	if (screen.primary) then
		for dummy, c in ipairs(clients) do
			c:move_to_screen(screen.primary.index)
			awful.placement.no_offscreen(c)
		end
	end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and awful.client.focus.filter(c) then
		client.focus = c
	end
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}


awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = true
