pcall(require, "luarocks.loader")

local gears = require("gears")
local gdebug = require("gears.debug")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local cairo = require("lgi").cairo
local Rsvg = require('lgi').Rsvg
local dpi = beautiful.xresources.apply_dpi
local capi = {
	drawin = drawin,
	root = root,
	awesome = awesome,
	screen = screen
}

home = os.getenv("HOME")
confdir = home .. "/.config/awesome"
themes = confdir .. "/themes"
active_theme = themes .. "/simple-dark"

--terminal = "alacrittyc"
terminal = "urxvtc"
editor = os.getenv("EDITOR")
gui_editor = "kwrite"
browser = "firefox-bin"
tasks = terminal .. " -e htop"
launch_tv = "mpv --demuxer=lavf --demuxer-lavf-format=mpegts --vf=vavpp:deint=auto:interlaced-only=yes --demuxer-lavf-o-add=fflags=+nobuffer --demuxer-lavf-probe-info=nostreams --demuxer-lavf-analyzeduration=0 --force-window=immediate http://192.168.1.111:8001/"

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


local function render_svg(path, scaling)
	local svg = Rsvg.Handle.new_from_file(path)
	local dim = svg:get_dimensions()
	local img = cairo.ImageSurface(cairo.Format.ARGB32, dim.width * scaling, dim.height * scaling)
	local cr = cairo.Context(img)
	cr:scale(scaling, scaling)
	svg:render_cairo(cr)
	return img
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


for s in screen do
	gears.wallpaper.maximized(beautiful.wallpaper, s, false)
end


local function setup_screen(s)
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
end

awful.screen.connect_for_each_screen(setup_screen)
--
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
		squares_sel = render_svg(beautiful.taglist_squares_sel, scaling),
		squares_unsel = render_svg(beautiful.taglist_squares_unsel, scaling),
	}
	for _, w in ipairs(s.taglist_elements) do
		w.forced_width = taglist_size
		w.forced_height = taglist_size
		w.bottom = taglist_margin
		w.right = taglist_margin
	end
	s.taglist:_do_taglist_update_now()

	s.main_menu:hide()
	s.main_menu = awful.menu(get_main_menu(s))
	s.main_menu.wibox:set_bg('#ff0000')

	s.launcher:set_image(render_svg(theme.launch, scaling))
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

			--print(gradient_stops)

			--local bg_start = 0
			--local bg_height = height
			--if beautiful.wibar_border_bottom ~= nil then
			--	cr:set_source(gears.color(beautiful.wibar_border_bottom))
			--	cr:rectangle(0, height - dpi(1, s), width, dpi(1, s))
			--	cr:fill()
			--	bg_height = bg_height - dpi(1, s)
			--end
			--if beautiful.wibar_border_top ~= nil then
			--	cr:set_source(gears.color(beautiful.wibar_border_top))
			--	cr:rectangle(0, 0, width, dpi(1, s))
			--	cr:fill()
			--	bg_start = bg_start + dpi(1, s)
			--	bg_height = bg_height - dpi(1, s)
			--end
			--if beautiful.wibar_bg_bottom == nil then
			--	cr:set_source(gears.color(beautiful.wibar_bg or beautiful.bg_normal))
			--else
			--	cr:set_source(gears.color('linear:0,0:0,'..height..':0,'..beautiful.wibar_bg..':1,'..beautiful.wibar_bg_bottom))
			--end
			--cr:rectangle(0, bg_start, width, bg_height)
			--print(tostring(0.5))
			--cr:fill()
		end
	})

	s.main_menu = awful.menu(get_main_menu(s))

	s.launcher = awful.widget.launcher({
		image = beautiful.launch,
		menu = s.main_menu
	})
	s.launcher:set_image(render_svg(theme.launch, scaling))
	s.launcher:set_buttons(gears.table.join(
		awful.button({ }, 1, function() s.main_menu:toggle() end)
	))

	s.taglist_elements = {}
	s.taglist_args = {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = gears.table.join(taglist_common.buttons),
		style = {
			squares_sel = render_svg(beautiful.taglist_squares_sel, scaling),
			squares_unsel = render_svg(beautiful.taglist_squares_unsel, scaling),
		},
		layout = {
			spacing = 0,
			layout  = wibox.layout.grid,
			forced_num_cols = 3,
			forced_num_rows = 3,
		},
		widget_template = {
			id = "container_role",
			widget = wibox.container.margin,
			forced_width = dpi(6, s),
			forced_height = dpi(6, s),
			bottom = dpi(1, s),
			right = dpi(1, s),
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
			create_callback = function(self, t, index, objects)
				local s = t.screen
				table.insert(s.taglist_elements, self)
			end,
		},
	}

	s.taglist = awful.widget.taglist(s.taglist_args)

	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(s.launcher)
	left_layout:add(s.taglist)

	s.tool_bar:setup {
		layout = wibox.layout.align.horizontal,
		left_layout,
	}
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

