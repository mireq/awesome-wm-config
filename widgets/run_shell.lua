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
				widget = wibox.container.background
			},
			valign = 'center',
			layout = wibox.container.place
		}

		return w
	end

	function widget_instance:launch()
		local s = awful.screen.focused()
		if not self._cached_wiboxes[s] then
			self._cached_wiboxes[s] = {}
		end
		if not self._cached_wiboxes[s][1] then
			self._cached_wiboxes[s][1] = self:_create_wibox()
		end
		self._cached_wiboxes[s][1]:get_children_by_id('margin')[1]:set_left(dpi(8, s))
		local w = self._cached_wiboxes[s][1]

		if capi.awesome.composite_manager_running then
			w.width = s.geometry.width
			w.height = s.geometry.height
		else
			local input_width = s.geometry.width - dpi(100, s)
			local input_height = dpi(30, s)
			input_width = math.min(dpi(800, s), input_width)

			w.width = input_width
			w.height = input_height
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
