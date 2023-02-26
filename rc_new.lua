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


--screen.connect_signal("added", function(s)
--	print("added", s)
--end)
--
--screen.connect_signal("list", function()
--	print("list signal")
--end)
--
--for s in screen do
--	print("screen", s)
--end

screen.connect_signal("request::desktop_decoration", function(s)
	--a = wibox.widget{
	--	markup = 'This <i>is</i> a <b>textbox</b>!!!',
	--	align  = 'center',
	--	valign = 'center',
	--	widget = wibox.widget.textbox
	--}
	--s.tool_bar = awful.wibar({
	--	position = "top",
	--	screen = s,
	--	height = dpi(18, s),
	--	bg = '#ff0000'
	--})
	--s.tool_bar:remove()
	--s.tool_bar = nil
	--for i=0, 10000 do
	--	w = wibox({
	--		x = 0,
	--		y = 0,
	--		width = 100,
	--		height = 100,
	--		bg = '#ff0000'
	--	})
	--	--w.visible = false
	--	--local w = awful.wibar({
	--	--	position = "top",
	--	--	screen = s,
	--	--	height = dpi(18, s),
	--	--	bg = '#ff0000'
	--	--})
	--	--w.visible = false
	--	--w:remove()
	--	if i % 100 == 0 then
	--		collectgarbage("collect")
	--	end
	--end
end)

awful.run_test = function()
	widgets = {}
	for i=0, 100 do
		w = wibox({
			x = 0,
			y = 0,
			width = 100,
			height = 100,
			bg = '#ff0000',
		})
		w.visible = true
		table.insert(widgets, w)
	end
	gears.timer {
		timeout   = 0.05,
		call_now  = false,
		autostart = true,
		callback  = function()
			for _, w in ipairs(widgets) do
				w.visible = false
			end
			widgets = {}
			collectgarbage("collect")
		end
	}
end

--s = screen.fake_add(100, 100, 100, 100); s:fake_remove()
--
