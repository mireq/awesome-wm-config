local M = {}

local gdebug = require("gears.debug")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local awful = require("awful")
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


return M
