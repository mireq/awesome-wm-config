-- Inspiration
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/run-shell

local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local completion = require("awful.completion")
local gfs = require("gears.filesystem")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local capi = {
	awesome = awesome,
	screen = screen,
}


local widget = {}
local run_shell = awful.widget.prompt()


function widget.new()
	local widget_instance = {
		_cached_wiboxes = {}
	}

	function widget_instance:_create_wibox()
		local s = awful.screen.focused()
		local input_width = s.geometry.width - dpi(100, s)
		local input_height = dpi(30, s)
		input_width = math.min(dpi(800, s), input_width)

		local w = wibox {
			visible = false,
			ontop = true,
			height = 1,
			width = 1,
			bg = '#00000080'
		}

		w:setup {
			{
				{
					markup = '<span font="Ubuntu 22">Run shell command\n\n</span>',
					widget = wibox.widget.textbox,
					halign = 'center',
					id = 'title'
				},
				{
					{
						{
							run_shell,
							layout = wibox.container.margin,
							id = 'margin',
						},
						id = 'left',
						layout = wibox.layout.fixed.horizontal
					},
					bg = beautiful.wibar_bg,
					shape_border_color = beautiful.fg_focus,
					shape_border_width = 1,
					forced_width = input_width,
					forced_height = input_height,
					widget = wibox.container.background,
					id = 'background'
				},
				layout = wibox.layout.fixed.vertical
			},
			valign = 'center',
			layout = wibox.container.place
		}

		return w
	end

	function widget_instance:launch()
		local s = awful.screen.focused()

		local input_width = s.geometry.width - dpi(100, s)
		local input_height = dpi(30, s)
		input_width = math.min(dpi(800, s), input_width)

		if not self._cached_wiboxes[s] then
			self._cached_wiboxes[s] = {}
		end
		if not self._cached_wiboxes[s][1] then
			self._cached_wiboxes[s][1] = self:_create_wibox()
		end

		local margin = self._cached_wiboxes[s][1]:get_children_by_id('margin')[1]
		margin:set_left(dpi(8, s))
		local background = self._cached_wiboxes[s][1]:get_children_by_id('background')[1]
		background.forced_width = input_width
		background.forced_height = input_height
		local w = self._cached_wiboxes[s][1]
		local title = self._cached_wiboxes[s][1]:get_children_by_id('title')[1]

		if capi.awesome.composite_manager_running then
			w.width = s.geometry.width
			w.height = s.geometry.height
			title.visible = true
		else
			w.width = input_width
			w.height = input_height
			title.visible = false
		end

		w.visible = true

		awful.placement.centered(w, { margins = { top = 0 }, parent = awful.screen.focused() })
		awful.prompt.run {
			prompt = 'Run: ',
			bg_cursor = beautiful.fg_focus,
			textbox = run_shell.widget,
			completion_callback = completion.shell,
			exe_callback = function(...)
				run_shell:spawn_and_handle_error(...)
			end,
			history_path = gfs.get_cache_dir() .. "/history",
			done_callback = function() w.visible = false end
		}
	end

	return widget_instance
end


local function get_default_widget()
	if not widget.default_widget then
		widget.default_widget = widget.new()
	end
	return widget.default_widget
end


function widget.launch(...)
	return get_default_widget():launch(...)
end


capi.screen.connect_signal("removed", function(s)
	if widget.default_widget then
		widget.default_widget._cached_wiboxes[s] = nil
	end
end)


return widget
