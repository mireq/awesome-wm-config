local M = {}

local gdebug = require("gears.debug")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local awful = require("awful")
local Rsvg = require('lgi').Rsvg
local cairo = require("lgi").cairo
local dpi = beautiful.xresources.apply_dpi


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


return M
