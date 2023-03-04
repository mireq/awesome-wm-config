pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local cairo = require("lgi").cairo
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

beautiful.init(active_theme .. "/theme_new.lua")

for s in screen do
	gears.wallpaper.maximized(beautiful.wallpaper, s, false)
end


--screen.connect_signal("added", function(s)
--	print("added", s)
--end)
--
--screen.connect_signal("list", function()
--	print("list signal")
--end)
--

screen.connect_signal("request::desktop_decoration", function(s)

	s.tool_bar = awful.wibar({
		position = "top",
		screen = s,
		height = dpi(18, s),
		bgimage = function(context, cr, width, height)
			if beautiful.wibar_bg_bottom == nil then
				cr:set_source(gears.color(beautiful.wibar_bg or beautiful.bg_normal))
			else
				cr:set_source(gears.color('linear:0,0:0,'..height..':0,'..beautiful.wibar_bg..':1,'..beautiful.wibar_bg_bottom))
			end
			cr:rectangle(0, 0, width, height)
			cr:fill()
			if beautiful.wibar_border_bottom ~= nil then
				cr:set_source(gears.color(beautiful.wibar_border_bottom))
				cr:rectangle(0, height - dpi(1, s), width, dpi(1, s))
				cr:fill()
			end
			if beautiful.wibar_border_top ~= nil then
				cr:set_source(gears.color(beautiful.wibar_border_top))
				cr:rectangle(0, 0, width, dpi(1, s))
				cr:fill()
			end
		end
	})
end)

awful.run_test = function()
	s = screen.fake_add(20, 20, 500, 400)
	gears.timer {
		timeout   = 0.05,
		call_now  = false,
		autostart = true,
		single_shot = true,
		callback  = function()
			s:fake_remove()
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

