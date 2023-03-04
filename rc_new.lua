pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
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
		bg = '#ff0000'
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

