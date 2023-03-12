local wibox = require("wibox")
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local fixed = require("wibox.layout.fixed")


local status_magnitude_widget = { mt = {} }

function status_magnitude_widget:layout(context, ...)
	local result = {}
	for _, w in pairs(self._private.widgets) do
		if w.visible then
			table.insert(result, base.place_widget_at(w, 0, 0, ...))
		end
	end
	return result
end

function status_magnitude_widget:fit(context, ...)
	return base.fit_widget(self, context, self._private.widgets[1], ...)
end

status_magnitude_widget.set_widget = base.set_widget_common

function status_magnitude_widget:get_widget()
	return self._private.widgets[1]
end

function status_magnitude_widget:get_children()
	return self._private.widgets
end

function status_magnitude_widget:set_children(children)
	self._private.widgets = children
end

function status_magnitude_widget:get_options()
end

function status_magnitude_widget:set_options(options)
	self:update_contents()
end

function status_magnitude_widget:get_value()
	return self._private.value
end

function status_magnitude_widget:set_value(value)
	self._private.value = value
	self:update_contents()
end

function status_magnitude_widget:get_special()
	return self._private.special
end

function status_magnitude_widget:set_special(special)
	self._private.special = special
	self:update_contents()
end

function status_magnitude_widget:set_options(options)
	local widgets = {}
	local widgets_value = {}
	local widgets_special = {}

	table.insert(widgets, wibox.widget.imagebox(options.icon .. 'base.svg'))
	for i = 1, options.count do
		local w = wibox.widget.imagebox(options.icon .. i .. '.svg')
		table.insert(widgets, w)
		table.insert(widgets_value, w)
		w:set_visible(false)
	end
	if options.special ~= nil then
		for _, special_key in ipairs(options.special) do
			local w = wibox.widget.imagebox(options.icon .. special_key .. '.svg')
			table.insert(widgets, w)
			widgets_special[special_key] = w
			w:set_visible(false)
		end
	end

	if options.stylesheet ~= nil then
		for _, w in pairs(widgets) do
			w.stylesheet = options.stylesheet
		end
	end

	self._private.count = options.count
	self._private.widgets = widgets
	self._private.widgets_value = widgets_value
	self._private.widgets_special = widgets_special

	self:update_contents()
end

function status_magnitude_widget:update_contents(special)
	if self._private.special == nil then
		for name, w in pairs(self._private.widgets_special) do
			w:set_visible(false)
		end
		local value = 1 + self._private.value * self._private.count
		for num, w in ipairs(self._private.widgets_value) do
			local opacity = value - num
			if opacity < 0 then
				w:set_visible(false)
			else
				if opacity > 1 then
					w:set_opacity(1)
				else
					w:set_opacity(opacity)
				end
				w:set_visible(true)
			end
		end
	else
		for _, w in ipairs(self._private.widgets_value) do
			w:set_visible(false)
		end
		for name, w in pairs(self._private.widgets_special) do
			w:set_visible(name == self._private.special)
		end
	end
	self:emit_signal("widget::layout_changed")
	self:emit_signal("widget::redraw_needed")
end

local function new(options)
	local ret = fixed.horizontal()

	gtable.crush(ret, status_magnitude_widget, true)

	ret._private.h_offset = 0
	ret._private.v_offset = 0

	ret._private.value = 0
	ret._private.special = nil

	if options ~= nil then
		ret:set_options(options)
	end

	return ret
end


function status_magnitude_widget.mt:__call(...)
	return new(...)
end


return setmetatable(status_magnitude_widget, status_magnitude_widget.mt)
