local wibox = require("wibox")
local base = require("wibox.widget.base")
local common = require("awful.widget.common")
local gtable = require("gears.table")
local fixed = require("wibox.layout.fixed")
local gdebug = require("gears.debug")
local timer = require("gears.timer")
local beautiful = require("beautiful")
local lgi = require 'lgi'
local Gio = lgi.Gio
local GObject = lgi.GObject

-- Connect so system DBus
local system_bus = nil

-- global device manager state
local signals = {}
local device_manager = {devices = {}}

function device_manager.connect_signal(name, callback)
	signals[name] = signals[name] or {}
	table.insert(signals[name], callback)
end

function device_manager.disconnect_signal(name, callback)
	signals[name] = signals[name] or {}

	for k, v in ipairs(signals[name]) do
		if v == callback then
			table.remove(signals[name], k)
			break
		end
	end
end

function device_manager.emit_signal(name, ...)
	signals[name] = signals[name] or {}

	for _, cb in ipairs(signals[name]) do
		cb(...)
	end
end

local cancellable = Gio.Cancellable()
Gio.bus_get(
	Gio.BusType.SYSTEM,
	cancellable,
	function (object, result)
		local connection, err = Gio.bus_get_finish(result)
		if err then
			print(tostring(err))
		else
			system_bus = connection
		end
	end
)

local udisks_mount_widget = { mt = {} }

local function get_screen(s)
	return s and screen[s]
end

local function default_template()
	return {
		id = 'icon_margin_role',
		widget = wibox.container.margin,
		{
			id = 'icon_role',
			widget = wibox.widget.imagebox,
			image = beautiful.widget_temp,
			stylesheet = 'svg { fill: '..beautiful.fg_normal..'; }',
		}
	}
end

local function widget_label(c, args, tb)
	return "", nil, nil, beautiful.widget_temp, {}
end

local function widget_update(s, self, buttons, filter, data, style, update_function, args)
	local function label(c, tb) return widget_label(c, style, tb) end

	update_function(self._private.base_layout, buttons, label, data, data, {
		widget_template = self._private.widget_template or default_template(),
		create_callback = create_callback,
	})
end

function udisks_mount_widget:layout(_, width, height)
	if self._private.base_layout then
		return { base.place_widget_at(self._private.base_layout, 0, 0, width, height) }
	end
end

function udisks_mount_widget:fit(context, width, height)
	if not self._private.base_layout then
		return 0, 0
	end

	return base.fit_widget(self, context, self._private.base_layout, width, height)
end

local function new(args)
	local w = base.make_widget(nil, nil, {
		enable_properties = true,
	})

	local screen = get_screen(args.screen)
	local uf = args.update_function or common.list_update

	gtable.crush(w, udisks_mount_widget, true)
	gtable.crush(w._private, {
		style = args.style or {},
		buttons = args.buttons,
		update_function = args.update_function,
		widget_template = args.widget_template,
		screen = screen
	})

	w._private.base_layout = fixed.horizontal()
	w._private.pending_update = false

	local data = setmetatable({}, { __mode = 'k' })

	function w._do_update_now()
		widget_update(w._private.screen, w, w._private.buttons, w._private.filter, data, args.style, uf, args)
		w._private.pending_update = false
	end

	function w._do_update()
		if not w._private.pending_update then
			timer.delayed_call(w._do_update_now)
			w._private.pending_update = true
		end
	end

	w._do_update()

	gtable.crush(w, udisks_mount_widget, true)

	return w
end

function udisks_mount_widget.mt:__call(...)
	return new(...)
end


return setmetatable(udisks_mount_widget, udisks_mount_widget.mt)
