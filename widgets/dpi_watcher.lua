local base = require("wibox.widget.base")
local gtable = require("gears.table")


local dpi_watcher = { mt = {} }

function dpi_watcher:update_dpi(dpi)
	if self._private.dpi == dpi then
		return
	end
	self._private.dpi = dpi
	if self._private.dpi_callback ~= nil then
		self._private.dpi_callback(self)
	end
end

function dpi_watcher:layout(context, ...)
	self:update_dpi(context.screen.dpi)
	return { base.place_widget_at(self._private.widget, 0, 0, ...) }
end

function dpi_watcher:fit(context, ...)
	self:update_dpi(context.screen.dpi)
	return base.fit_widget(self, context, self._private.widget, ...)
end

dpi_watcher.set_widget = base.set_widget_common

function dpi_watcher:get_widget()
	return self._private.widget
end

function dpi_watcher:get_children()
	return {self._private.widget}
end

function dpi_watcher:set_children(children)
	self:set_widget(children[1])
end

function dpi_watcher:get_dpi_callback()
	return self._private.dpi_callback
end

function dpi_watcher:set_dpi_callback(dpi_callback)
	self._private.dpi_callback = dpi_callback
end

local function new(widget, dpi_callback)
	local ret = base.make_widget(nil, nil, {enable_properties = true})
	gtable.crush(ret, dpi_watcher, true)
	ret:set_widget(widget)
	ret._private.dpi = 0
	ret._dpi_callback = dpi_callback
	return ret
end


function dpi_watcher.mt:__call(...)
	return new(...)
end


return setmetatable(dpi_watcher, dpi_watcher.mt)
