local M = {}

local gears = require("gears")
local gdebug = require("gears.debug")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local awful = require("awful")
local Rsvg = require('lgi').Rsvg
local cairo = require("lgi").cairo
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")


local text_width_calculator_widget = wibox.widget.textbox()


M.update_widget_template_attributes = function(widget_template, attributes)
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


M.show_hotkeys_help = function()
	local s = awful.screen.focused()
	beautiful.hotkeys_border_width = dpi(1, s)
	beautiful.hotkeys_group_margin = dpi(6, s)
	hotkeys_popup.show_help()
end


M.render_svg = function(path, scaling)
	local svg = Rsvg.Handle.new_from_file(path)
	local dim = svg:get_dimensions()
	local img = cairo.ImageSurface(cairo.Format.ARGB32, dim.width * scaling, dim.height * scaling)
	local cr = cairo.Context(img)
	cr:scale(scaling, scaling)
	svg:render_cairo(cr)
	return img
end


M.calculate_text_width = function(s, text)
	text_width_calculator_widget:set_markup(text)
	return select(1, text_width_calculator_widget:get_preferred_size(s))
end


M.mix_color = function(c1, c2, value)
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


M.set_color_alpha = function(c, alpha)
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


M.calculate_gradient_color = function(value, gradient)
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


return M
