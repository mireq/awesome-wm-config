local wibox = require("wibox")
local base = require("wibox.widget.base")
local gtable = require("gears.table")
local fixed = require("wibox.layout.fixed")


local status_magnitude_widget = { mt = {} }

function status_magnitude_widget:layout(context, ...)
	local result = {}
	for _, w in pairs(self._private.widgets) do
		table.insert(result, base.place_widget_at(w, 0, 0, ...))
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

local function new(opts)
	local ret = fixed.horizontal()
	local widgets_value = {}
	local widgets_special = {}

	table.insert(ret._private.widgets, wibox.widget.imagebox(opts.icon .. 'base.svg'))
	for i = 1, opts.count do
		local w = wibox.widget.imagebox(opts.icon .. i .. '.svg')
		table.insert(ret._private.widgets, w)
		table.insert(widgets_value, w)
		w:set_opacity(0)
	end
	if opts.special ~= nil then
		for _, special_key in ipairs(opts.special) do
			local w = wibox.widget.imagebox(opts.icon .. special_key .. '.svg')
			table.insert(ret._private.widgets, w)
			widgets_special[special_key] = w
			w:set_opacity(0)
		end
	end

	ret._private.widgets_value = widgets_value
	ret._private.widgets_special = widgets_special

	ret._private.h_offset = 0
	ret._private.v_offset = 0

	gtable.crush(ret, status_magnitude_widget, true)
	return ret
end


function status_magnitude_widget.mt:__call(...)
	return new(...)
end


return setmetatable(status_magnitude_widget, status_magnitude_widget.mt)
