---[[                                          ]]--
--                                               -
--          Inspired from WM 3.5.+ config        --
--           github.com/copycat-killer           --
--                                               -
--[[                                           ]]--

-- {{{ Required Libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local naughty = require("naughty")
local vicious = require("vicious")
local udisks = require("udisks")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local calendar = require("calendar")
local popups = require("popups")
local run_shell = require("awesome-wm-widgets.run-shell.run-shell")
local cairo = require("lgi").cairo

require("awful.rules")
require("awful.autofocus")
require("awful.hotkeys_popup.keys")

-- awful.util.spawn_with_shell("setxkbmap -layout sk,us -variant qwerty, -option terminate:ctrl_alt_bksp,grp:shifts_toggle,grp_led:scroll,keypad:pointerkeys -model microsoftprooem")

-- {{{ Error Handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = err
		})
		in_error = false
	end)
end

-- }}}


-- {{{ Variable Definitions

-- Useful Paths
home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
scriptdir = confdir .. "/scripts/"
themes = confdir .. "/themes"
active_theme = themes .. "/powerarrow-darker"

-- Themes define colours, icons, and wallpapers
beautiful.init(active_theme .. "/theme.lua")

terminal = "urxvtc"
editor = os.getenv("EDITOR")
gui_editor = "kwrite"
browser = "firefox-bin"
browser2 = "google-chrome"
mail = terminal .. " -e mutt "
chat = terminal .. " -e irssi "
tasks = terminal .. " -e htop "
iptraf = terminal .. " -g 180x54-20+34 -e sudo iptraf-ng -i all "
musicplr = terminal .. " -g 130x34-320+16 -e ncmpcpp "
udisks.filemanager = "konqueror"

local panel_font = 'UbuntuCondensed 9'

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Additional settings
titlebar_position = "right"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
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
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}


-- {{{ Helper functions
local function client_menu_toggle_fn()
	local instance = nil

	return function ()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ theme = { width = 250 } })
		end
	end
end


local width_calculator = wibox.widget.textbox()

local function calculate_text_width(s, text)
	width_calculator:set_markup('<span font="UbuntuCondensed 9">MMM 00.00 00:00</span>')
	return select(1, width_calculator:get_preferred_size(s))
end
-- }}}



-- {{{ Menu
myaccessories = {
	{ "archives", "ark" },
	{ "file manager", "konqueror" },
	{ "editor", gui_editor },
}
myinternet = {
	{ "browser", browser },
}
mygames = {
	{ "PSX", "pcsxr" },
	{ "Super NES", "zsnes" },
}
mygraphics = {
	{ "gimp" , "gimp" },
	{ "inkscape", "inkscape" },
	{ "darktable" , "darktable" }
}
myoffice = {
	{ "writer" , "lowriter" },
	{ "impress" , "loimpress" },
}
mysystem = {
	{ "htop" , terminal .. " -e htop " },
	--{ "htop", 'urxvt -font "xft:DejaVu\\ Sans\\ Mono for Powerline:style=normal:pixelsize=18" -depth 32 -background "rgba:0000/0000/0000/2000" -e htop'},
	{ "hotkeys", function() return false, hotkeys_popup.show_help end},
	{ "restart", awesome.restart },
	{ "quit", function() awesome.quit() end},
	{ "poweroff", "loginctl poweroff"},
	{ "suspend", "loginctl suspend"}
}
mydemo = {
	{ "Demo" , 'mpv /home/mirec/video.mkv' },
	{ "Eletctic whiskey" , 'urxvt -font "xft:DejaVu\\ Sans\\ Mono for Powerline:style=normal:pixelsize=16" -depth 32 -background "rgba:0000/0000/0000/8000" -e /home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/7lX3Rj-electric-whiskey.json --resolution 1200x800 --fps 60 --tile-size 600x400' },
	{ "Ether" , 'urxvt -font "xft:DejaVu\\ Sans\\ Mono for Powerline:style=normal:pixelsize=16" -depth 32 -background "rgba:0000/0000/0000/8000" -e /home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/MsjSW3-ether.json --resolution 840x520 --fps 60 --tile-size 420x260' },
	{ "Rounded vornoi borders" , 'urxvt -font "xft:DejaVu\\ Sans\\ Mono for Powerline:style=normal:pixelsize=16" -depth 32 -background "rgba:0000/0000/0000/8000" -e /home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/ll3GRM-rounded-vornoi-borders.json --resolution 960x400 --fps 60 --tile-size 480x200' },
	{ "Seascape" , '/home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/Ms2SD1-seascape.json --resolution 640x360 --fps 30 --tile-size 320x180' },
	{ "Voxel flythrough" , '/home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/MdGXWG-voxel-flythrough.json --resolution 720x400 --tile-size 180x200 --fps 30' },
	{ "Hex voxel scene" , '/home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/4dsBz4-hex-voxel-scene.json --resolution 480x260 --tile-size 240x130 --fps 30' },
	{ "Fractal land" , '/home/mirec/Documents/Praca/python/shadertoy/code/shadertoy.py render /home/mirec/Documents/Praca/python/shadertoy/demo/XsBXWt-fractal-land/XsBXWt-fractal-land.json --resolution 640x360 --fps 30 --tile-size 320x180' }
}
mymainmenu = awful.menu({
	items = {
		{ "accessories" , myaccessories },
		{ "graphics" , mygraphics },
		{ "internet" , myinternet },
		{ "games" , mygames },
		{ "office" , myoffice },
		{ "system" , mysystem },
		{ "demo" , mydemo },
	}
})
mylauncher = awful.widget.launcher({
	image = beautiful.awesome_icon,
	menu = mymainmenu
})
-- }}}


-- Separators
local spr = wibox.widget.textbox(' ')
local arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
local arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
local arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)
-- }}}


-- {{{ Layout
local mywibox = {}
local mypromptbox = {}
local mylayoutbox = {}
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end)
)
local mytasklist = {}
mytasklist.buttons = gears.table.join(
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
	awful.button({ }, 3, client_menu_toggle_fn()),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
	end)
)

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

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Volume widget logic
local cardid  = 0
local channel = "Master"
local function volume(mode, widget)
	if mode == "up" then
		awful.util.spawn("amixer set Master playback 1%+", false )
		vicious.force({ widget })
	elseif mode == "down" then
		awful.util.spawn("amixer set Master playback 1%-", false )
		vicious.force({ widget })
	else
		awful.util.spawn("amixer set Master playback toggle", false )
		awful.util.spawn("amixer set Speaker playback on", false )
		vicious.force({ widget })
	end
end

local volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
local volumewidget = wibox.widget.textbox()
volumewidget:buttons(awful.util.table.join(
	awful.button({ }, 4, function () volume("up", volumewidget) end),
	awful.button({ }, 5, function () volume("down", volumewidget) end),
	awful.button({ }, 1, function () volume("mute", volumewidget) end)
))
vicious.register(volumewidget, vicious.widgets.volume,
	function (widget, args)
		if (args[2] ~= "♩" ) then
			if (args[1] == 0) then
				volicon:set_image(beautiful.widget_vol_no)
			elseif (args[1] <= 50) then
				volicon:set_image(beautiful.widget_vol_low)
			else
				volicon:set_image(beautiful.widget_vol)
			end
		else
			volicon:set_image(beautiful.widget_vol_mute)
		end
		return '<span font="'..panel_font..'"> ' .. args[1] .. '% </span>'
	end, 15, "Master")

-- Mail widget
--mygmail = wibox.widget.textbox()
--notify_shown = false
--gmail_t = awful.tooltip({ objects = { mygmail },})
local mygmailimg = wibox.widget.imagebox(beautiful.widget_mail)
--vicious.register(mygmail, vicious.widgets.gmail,
--function (widget, args)
--  notify_title = "Hai un nuovo messaggio"
--  notify_text = '"' .. args["{subject}"] .. '"'
--  gmail_t:set_text(args["{subject}"])
--  gmail_t:add_to_object(mygmailimg)
--  if (args["{count}"] > 0) then
--	if (notify_shown == false) then
--	  if (args["{count}"] > 1) then 
--		  notify_title = "Hai " .. args["{count}"] .. " nuovi messaggi"
--		  notify_text = 'Ultimo: "' .. args["{subject}"] .. '"'
--	  else
--		  notify_title = "Hai un nuovo messaggio"
--		  notify_text = args["{subject}"]
--	  end
--	  naughty.notify({ title = notify_title, text = notify_text,
--	  timeout = 7,
--	  position = "top_left",
--	  icon = beautiful.widget_mail_notify,
--	  fg = beautiful.fg_urgent,
--	  bg = beautiful.bg_urgent })
--	  notify_shown = true
--	end
--	return ' <span font="'..panel_font..'">' .. args["{count}"] .. ' </span>'
--  else
--	notify_shown = false
--	return ""
--  end
--end, 60)
--mygmail:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(mail, false) end)))

-- MEM widget
local memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
local memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, function(widget, args) return ' <span font="'..panel_font..'">' .. string.format("%4d", args[2]) .. "MB</span> " end, 3)

-- CPU widget
local cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
local cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, function(widget, args) return ' <span font="'..panel_font..'">' .. string.format("%2d", args[1]) .. "% </span>" end, 3)
cpuicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn(tasks, false) end)))
popups.htop(cpuwidget, {
	title_color = "#ffffff",
	user_color = "#00ff00",
	root_color = "#ffff00",
	terminal = "urxvt"
})

-- blingbling.popups.htop(cpuwidget, {
-- 	title_color = "#ffffff",
-- 	user_color = "#00ff00",
-- 	root_color = "#ffff00",
-- 	terminal = "urxvt"
-- })

-- Temp widget
local tempicon = wibox.widget.imagebox()
tempicon:set_image(beautiful.widget_temp)
local tempwidget = wibox.widget.textbox()
vicious.register(tempwidget, vicious.widgets.thermal, '<span font="'..panel_font..'"> $1°C </span>', 15, {"thermal_zone0", "sys"} )

-- Battery widget
local baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_battery)

local function batstate()
	local file = io.open("/sys/class/power_supply/BAT0/status", "r")

	if (file == nil) then
		return "Cable plugged"
	end

	local batstate = file:read("*line")
	file:close()

	if (batstate == 'Discharging' or batstate == 'Charging') then
		return batstate
	elseif (batstate == 'Unknown') then
		return "Cable plugged"
	else
		return "Fully charged"
	end
end

batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat,
function (widget, args)
	local state = batstate()
	-- plugged
	if (state == 'Cable plugged') then
		baticon:set_image(beautiful.widget_ac)
		return '<span font="'..panel_font..'"> ' .. args[2] .. '%</span>'
	-- critical
	elseif (args[2] <= 5 and state == 'Discharging') then
		baticon:set_image(beautiful.widget_battery_empty)
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
	-- low
	elseif (args[2] <= 10 and state == 'Discharging') then
		baticon:set_image(beautiful.widget_battery_low)
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
	elseif (state == 'Charging') then
		baticon:set_image(beautiful.widget_battery_charging)
	else
		baticon:set_image(beautiful.widget_battery)
	end
	return '<span font="'..panel_font..'"> ' .. args[2] .. '% </span>'
end, 15, 'BAT0')

local function print_net(down_val, up_val)
	return '<span font="'..panel_font..'" color="#7AC82E"> ' .. down_val .. '</span> <span font="Terminus 7" color="#EEDDDD">↓↑</span> <span font="'..panel_font..'" color="#46A8C3">' .. up_val .. ' </span>'
end

-- Net widget
local netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net, function(widget, args)
	if args['{ppp0 down_kb}'] then
		return print_net(args['{ppp0 down_kb}'], args['{ppp0 up_kb}'])
	elseif args['{wlan0 down_kb}'] then
		return print_net(args['{wlan0 down_kb}'], args['{wlan0 up_kb}'])
	elseif args['{eth0 down_kb}'] then
		return print_net(args['{eth0 down_kb}'], args['{eth0 up_kb}'])
	end
	return print_net(0, 0)
end, 3)
local neticon = wibox.widget.imagebox()
neticon:set_image(beautiful.widget_net)
netwidget:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(iptraf) end)))
popups.netstat(netwidget, {
	title_color = "#ffffff",
	established_color = "#ffff00",
	listen_color = "#00ff00"
})

-- Textclock widget
local clockicon = wibox.widget.imagebox()
clockicon:set_image(beautiful.widget_clock)
local mytextclock = wibox.widget.textclock('<span font="UbuntuCondensed 9">%a %d.%m %H:%M</span>')
calendar({}):attach(mytextclock)

-- Separators
local spr = wibox.widget.textbox(' ')
local arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
local arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
local arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)


local function alternate_panel_bg(widget)
	return wibox.widget {
		widget,
		bg = '#313131',
		widget = wibox.container.background,
	}
end


awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	local textclock_width = calculate_text_width(s, '<span font="'..panel_font..'">MMM 00.00 00:00</span>')

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({ }, 1, function () awful.layout.inc( 1) end),
		awful.button({ }, 3, function () awful.layout.inc(-1) end),
		awful.button({ }, 4, function () awful.layout.inc( 1) end),
		awful.button({ }, 5, function () awful.layout.inc(-1) end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(18, s) })
	-- Upper left widgets
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(mylauncher)
	left_layout:add(s.mytaglist)
	left_layout:add(s.mypromptbox)
	left_layout:add(spr)

	-- Upper right widgets
	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(spr)
	right_layout:add(arrl)
	--right_layout:add(arrl_ld)
	--right_layout:add(mpdicon)
	--right_layout:add(mpdwidget)
	--right_layout:add(arrl_dl)
	right_layout:add(arrl_ld)
	right_layout:add(mygmailimg)
	--right_layout:add(mygmail)
	right_layout:add(arrl_dl)
	right_layout:add(memicon)
	right_layout:add(memwidget)
	right_layout:add(arrl_ld)
	right_layout:add(neticon)
	right_layout:add(alternate_panel_bg(netwidget))
	right_layout:add(arrl_dl)
	right_layout:add(tempicon)
	right_layout:add(tempwidget)
	right_layout:add(arrl_ld)
	right_layout:add(cpuicon)
	right_layout:add(alternate_panel_bg(cpuwidget))
	right_layout:add(arrl_dl)
	right_layout:add(baticon)
	right_layout:add(batwidget)
	right_layout:add(arrl_ld)
	right_layout:add(volicon)
	right_layout:add(alternate_panel_bg(volumewidget))
	right_layout:add(arrl_dl)
	right_layout:add(wibox.widget {
		layout = awful.widget.only_on_screen,
		screen = "primary",
		wibox.widget.systray(),
	})
	right_layout:add(wibox.widget {
		layout = awful.widget.only_on_screen,
		screen = "primary",
		udisks.widget
	})
	right_layout:add(arrl)
	right_layout:add(wibox.widget {
		widget = mytextclock,
		forced_width = textclock_width,
		align = "center"
	})
	right_layout:add(spr)
	right_layout:add(spr)
	right_layout:add(arrl_ld)
	right_layout:add(s.mylayoutbox)

	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		left_layout,
		s.mytasklist,
		right_layout
	}

	--right_layout:add(wibox.widget {
	--	{
	--		widget = mytextclock,
	--		forced_width = textclock_width,
	--		align = "center",
	--	},
	--	bg = '#000000',
	--	widget = wibox.container.background,
	--})
end)
-- }}}

vicious.suspend()
mytimer = gears.timer({ timeout = 10 })
mytimer:connect_signal("timeout", function()
	vicious.force({ memwidget, netwidget, tempwidget, cpuwidget, batwidget, volumewidget })
end)
mytimer:start()


-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
			  {description="show help", group="awesome"}),
	awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
			  {description = "view previous", group = "tag"}),
	awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
			  {description = "view next", group = "tag"}),
	awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
			  {description = "go back", group = "tag"}),
	awful.key({ modkey,           }, "Tab", awful.tag.history.restore,
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
	awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
			  {description = "show main menu", group = "awesome"}),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
			  {description = "swap with next client by index", group = "client"}),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
			  {description = "swap with previous client by index", group = "client"}),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
			  {description = "focus the next screen", group = "screen"}),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
			  {description = "focus the previous screen", group = "screen"}),
	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
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
	awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
			  {description = "open a terminal", group = "launcher"}),
	awful.key({ modkey, "Control" }, "F7", function () awful.spawn("/etc/acpi/actions/switchvideo.sh") end,
			  {description = "open a terminal", group = "launcher"}),
	awful.key({ modkey, "Control", "Shift" }, "r", awesome.restart,
			  {description = "reload awesome", group = "awesome"}),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit,
			  {description = "quit awesome", group = "awesome"}),

	awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
			  {description = "increase master width factor", group = "layout"}),
	awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
			  {description = "decrease master width factor", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
			  {description = "increase the number of master clients", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
			  {description = "decrease the number of master clients", group = "layout"}),
	awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
			  {description = "increase the number of columns", group = "layout"}),
	awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
			  {description = "decrease the number of columns", group = "layout"}),
	awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
			  {description = "select next", group = "layout"}),
	awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
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

	-- Prompt
	-- awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
	-- 		  {description = "run prompt", group = "launcher"}),
	awful.key({modkey}, "r", function () run_shell.launch() end),

	awful.key({ modkey }, "a",
			  function ()
				  awful.prompt.run {
					prompt       = "Run Lua code: ",
					textbox      = awful.screen.focused().mypromptbox.widget,
					exe_callback = awful.util.eval,
					history_path = awful.util.get_cache_dir() .. "/history_eval"
				  }
			  end,
			  {description = "lua execute prompt", group = "awesome"}),
	-- Menubar
	awful.key({ modkey }, "p", function() menubar.show() end,
			  {description = "show the menubar", group = "launcher"}),
	awful.key({ modkey, altkey, "Shift"   }, "r", function () awful.spawn("/usr/local/bin/record_desktop_toggle")                end,
			  {description = "record desktop", group = "launcher"}),

	--awful.key({ modkey, "v" }, "p", function () awful.spawn('sh -c \'xdotool type "`/home/mirec/Documents/Praca/python/django-utils/django-sample-data-generator/cli/generate.py w`"') end,
	--		  {description = "Generate paragrap of text", group = "utility"}),
	awful.key({ modkey }, "v",
		function()
			keygrabber.run(function(mod, key, event)
				if event == "release" then return end
				keygrabber.stop();
				if key == 'w' then
					awful.spawn.with_shell('sleep 0.1; sh -c \'xdotool type "`/home/mirec/Documents/Praca/python/django-utils/django-sample-data-generator/cli/generate.py w`"\'');
				elseif key == 'W' then
					awful.spawn.with_shell('sleep 0.1; sh -c \'xdotool type "`/home/mirec/Documents/Praca/python/django-utils/django-sample-data-generator/cli/generate.py uw`"\'');
				elseif key == 'p' then
					awful.spawn.with_shell('sleep 0.1; sh -c \'xdotool type "`/home/mirec/Documents/Praca/python/django-utils/django-sample-data-generator/cli/generate.py p 4`"\'');
				elseif key == 's' then
					awful.spawn.with_shell('sleep 0.1; sh -c \'xdotool type "`/home/mirec/Documents/Praca/python/django-utils/django-sample-data-generator/cli/generate.py s`"\'');
				end
			end)
		end
	),

    -- Volume controls
    awful.key({ }, "XF86AudioRaiseVolume", function () volume("up", volumewidget) end),
    awful.key({ }, "XF86AudioLowerVolume", function () volume("down", volumewidget) end),
    awful.key({ }, "XF86AudioMute", function () volume("mute", volumewidget) end),
    awful.key({ }, "XF86AudioMicMute", function () awful.util.spawn("amixer set Capture capture toggle", false ) end)
)

clientkeys = gears.table.join(
	awful.key({ modkey,           }, "f",
		function (c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{description = "toggle fullscreen", group = "client"}),
	awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
			  {description = "close", group = "client"}),
	awful.key({ altkey,           }, "F4",     function (c) c:kill()                         end,
			  {description = "close", group = "client"}),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
			  {description = "toggle floating", group = "client"}),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
			  {description = "move to master", group = "client"}),
	awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
			  {description = "move to screen", group = "client"}),
	awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
			  {description = "toggle keep on top", group = "client"}),
	awful.key({ modkey,           }, "x",      function (c) c.sticky = not c.sticky          end,
			  {description = "sticky", group = "client"}),
	awful.key({ modkey,           }, "c",      function (c) c.focusable = not c.focusable    end,
			  {description = "toggle focusable", group = "client"}),
	awful.key({ modkey,           }, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end ,
		{description = "minimize", group = "client"}),
	awful.key({ modkey,           }, "m",
		function (c)
			local border_width = c.border_width
			c.maximized = not c.maximized
			c.border_width = border_width
			c:raise()
		end ,
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

clientbuttons = gears.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ altkey }, 1, awful.mouse.client.move),
	awful.button({ altkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}




-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { },
	  properties = { border_width = beautiful.border_width,
					 border_color = beautiful.border_normal,
					 focus = awful.client.focus.filter,
					 raise = true,
					 keys = clientkeys,
					 buttons = clientbuttons,
					 screen = awful.screen.preferred,
					 placement = awful.placement.no_overlap+awful.placement.no_offscreen
	 }
	},
	{ rule = { class = "MPlayer" },
		properties = { floating = true } },
	{ rule = { class = "Wine" },
		properties = { border_width = 0 } },
	{ rule = { class = "kruler" },
		properties = { border_width = 0 } },
	{ rule = { class = "rofi" },
		properties = { border_width = 0, floating = true } },
	{ rule = { class = "pinentry" },
		properties = { floating = true } },
	{ rule = { class = "gimp" },
		properties = { floating = true } },
	{ rule = { class = "Jbox"},
		properties = { floating = true, border_width = 0, x = 16, y = 128, width = 800, height = 608 } },
	{ rule = { class = "Yakuake" },
		properties = { floating = true, border_width = 0 } },
	{ rule = { class = "Kile" },
		properties = { maximized_horizontal = false, maximized_vertical = false} },
	--{ rule = { class = "Firefox" },
	--	properties = { tag = "2" } },
	--{ rule = { class = "Kodi" },
	--	properties = { focusable=false } },
	-- Set Firefox to always map on tags number 2 of screen 1.

	-- Floating clients.
	{ rule_any = {
		instance = {
		  "DTA",  -- Firefox addon DownThemAll.
		  "copyq",  -- Includes session name in class.
		},
		class = {
		  "Arandr",
		  "Gpick",
		  "Kruler",
		  "MessageWin",  -- kalarm.
		  "Sxiv",
		  "Wpa_gui",
		  "pinentry",
		  "veromix",
		  "xtightvncviewer"},

		name = {
		  "Event Tester",  -- xev.
		},
		role = {
		  "AlarmWindow",  -- Thunderbird's calendar.
		  "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
		}
	  }, properties = { floating = true }},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = {type = { "normal", "dialog" }
	  }, properties = { titlebars_enabled = true }
	},

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

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
		secondary_layout:add(awful.titlebar.widget.iconwidget(c))
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
				awful.mouse.client.move(c)
			end),
			awful.button({ }, 3, function()
				client.focus = c
				c:raise()
				awful.mouse.client.resize(c)
			end)
		)
	)

	awful.titlebar(c, {position = titlebar_position, size = dpi(19)}):set_widget(layout)

	if c.class == 'URxvt' or c.class == 'Firefox' or c.class == 'Google-chrome' or c.class == "Wine" or c.class == "kruler" then
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
