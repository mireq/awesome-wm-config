local base = require("wibox.widget.base")
local beautiful = require("beautiful")
local fixed = require("wibox.layout.fixed")
local gears = require("gears")
local gtable = require("gears.table")
local utils = require("utils")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi


local battery_widget = { mt = {} }


function battery_widget:get_options()
	return self._private.options
end

function battery_widget:set_options(options)
	self:update_contents()
end

function battery_widget:get_value()
	return self._private.value
end

function battery_widget:set_value(value)
	self._private.value = value
	self:update_contents()
end

function battery_widget:get_bar_color()
	return self._private.bar_color
end

function battery_widget:set_bar_color(bar_color)
	self._private.bar_color = bar_color
	self:update_contents()
end

function battery_widget:set_options(options)
	if options.stylesheet ~= nil then
		self.stylesheet = options.stylesheet
	end

	self:update_contents()
end

function battery_widget:update_contents()
	self:emit_signal("widget::redraw_needed")
end

function battery_widget:draw(context, cr, width, height)
	local s = context.screen
	local value = self._private.value
	local full_bar = self._private.full_bar
	local empty_bar = self._private.empty_bar
	if value < 0 then
		value = 0
	end
	if value > 1 then
		value = 1
	end
	local neg_value = 1 - value
	local bar = {0, 0, 0, 0}
	for i = 1, 4 do
		bar[i] = utils.float_dpi(empty_bar[i] * neg_value + full_bar[i] * value, s)
	end

	cr:save()
	wibox.widget.imagebox.draw(self, context, cr, width, height)
	cr:restore()

	cr:save()
	cr:set_antialias()
	cr:set_source(gears.color(self._private.bar_color))
	cr:rectangle(bar[4], bar[1], bar[2] - bar[4], bar[3] - bar[1])
	cr:fill()
	cr:restore()
end

local function new(options)
	local theme = beautiful.get()
	local ret = wibox.widget.imagebox(theme.widget_battery)

	gtable.crush(ret, battery_widget, true)

	ret._private.value = 0
	ret._private.bar_color = theme.fg_normal
	ret._private.empty_bar = theme.widget_battery_empty_bar
	ret._private.full_bar = theme.widget_battery_full_bar

	if options ~= nil then
		ret:set_options(options)
	end

	return ret
end


function battery_widget.mt:__call(...)
	return new(...)
end


return setmetatable(battery_widget, battery_widget.mt)
