local M = {}

local gears = require("gears")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local awful = require("awful")
local Rsvg = require('lgi').Rsvg
local cairo = require("lgi").cairo
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")


local text_width_calculator_widget = wibox.widget.textbox()


function M.update_widget_template_attributes(widget_template, attributes)
	for widget_id, attrs in pairs(attributes) do
		if widget_template.id == widget_id then
			for attr, val in pairs(attrs) do
				widget_template[attr] = val
			end
		end
	end

	for __, subtemplate in ipairs(widget_template) do
		if type(subtemplate) == 'table' then
			M.update_widget_template_attributes(subtemplate, attributes)
		end
	end
end


function M.show_hotkeys_help()
	local s = awful.screen.focused()
	beautiful.hotkeys_border_width = dpi(1, s)
	beautiful.hotkeys_group_margin = dpi(6, s)
	hotkeys_popup.show_help()
end


function M.render_svg(path, scaling)
	local svg = Rsvg.Handle.new_from_file(path)
	local dim = svg:get_dimensions()
	local img = cairo.ImageSurface(cairo.Format.ARGB32, dim.width * scaling, dim.height * scaling)
	local cr = cairo.Context(img)
	cr:scale(scaling, scaling)
	svg:render_cairo(cr)
	return img
end


function M.calculate_text_width(s, text)
	text_width_calculator_widget:set_markup(text)
	return select(1, text_width_calculator_widget:get_preferred_size(s))
end


function M.mix_color(c1, c2, value)
	if value <= 0 then
		return c1
	end
	if value >= 1 then
		return c2
	end
	local value_neg = 1.0 - value
	local r1, g1, b1, a1 = gears.color.parse_color(c1)
	local r2, g2, b2, a2 = gears.color.parse_color(c2)

	return string.format(
		"#%02x%02x%02x%02x",
		math.floor((r1 * value_neg + r2 * value) * 255),
		math.floor((g1 * value_neg + g2 * value) * 255),
		math.floor((b1 * value_neg + b2 * value) * 255),
		math.floor((a1 * value_neg + a2 * value) * 255)
	)
end


function M.set_color_alpha(c, alpha)
	local r, g, b, a = gears.color.parse_color(c)
	a = a * alpha
	return string.format(
		"#%02x%02x%02x%02x",
		math.floor((r) * 255),
		math.floor((g) * 255),
		math.floor((b) * 255),
		math.floor((a) * 255)
	)
end


function M.calculate_gradient_color(value, gradient)
	local previous = gradient[1]
	local ratio = 0
	local color = previous[2]
	for i, step in ipairs(gradient) do
		if i ~= 1 then
			step_value = step[1]
			ratio = (value - previous[1]) / (step_value - previous[1])
			color = M.mix_color(previous[2], step[2], ratio)
		end
		if value < previous[1] then
			break
		end
		previous = step
	end
	return color
end


function M.format_number(value)
	local i, j, minus, int, fraction = tostring(value):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub('(%d%d%d)', '%1 ')
	return minus .. int:reverse():gsub('^,', '') .. fraction
end


-- calculate dpi value as float
function M.float_dpi(size, s)
	local ratio = s.dpi / 96
	return size * ratio
end


function M.get_config_dir()
	return debug.getinfo(1).source:match("@?(.*/)[^/]*/[^/]*")
end


function M.debounce(fn, delay, trigger_first)
	local arguments = nil
	local running = false
	local function closure(...)
		if arguments == nil and not running and trigger_first then
			fn(...)
		else
			arguments = {...}
		end
		if running then
			return
		end
		running = true
		gears.timer {
			timeout = delay,
			call_now = false,
			autostart = true,
			single_shot = true,
			callback = function()
				if arguments ~= nil then
					fn(unpack(arguments))
				end
				running = false
				arguments = nil
			end
		}
	end

	return closure
end


return M
