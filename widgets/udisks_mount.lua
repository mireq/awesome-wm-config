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
local device_manager = {devices = {}, drives={}}

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

local function parse_drives(conn, res, callback)
	local ret, err = system_bus:call_finish(res)
	local xml = ret.value[1]

	if err then
		print(err)
		return
	end

	local node = Gio.DBusNodeInfo.new_for_xml(xml)
	for _, node in ipairs(node.nodes) do
		print(node.path)
	end
end

local function parse_block_devices(conn, res, callback)
	local ret, err = system_bus:call_finish(res)
	local xml = ret.value[1]

	if err then
		print(err)
		return
	end

	local node = Gio.DBusNodeInfo.new_for_xml(xml)
	for _, node in ipairs(node.nodes) do
		print(node.path)
	end
end

local function parse_devices(conn, res, callback)
	local ret, err = system_bus:call_finish(res);

	if err then
		print(err)
		return
	end

	local object_list = ret:get_child_value(0)
	for num = 0, #object_list-1 do
		local dev_info = object_list:get_child_value(num)
		gdebug.dump(dev_info[1])
		print(dev_info[2]['org.freedesktop.UDisks2.Block'])
	end
end


local function rescan_devices()
	system_bus:call(
		'org.freedesktop.UDisks2',
		'/org/freedesktop/UDisks2/drives',
		'org.freedesktop.DBus.Introspectable',
		'Introspect',
		nil,
		nil,
		Gio.DBusConnectionFlags.NONE,
		-1,
		nil,
		function(conn, res)
			parse_drives(conn, res, callback)
		end
	)
	system_bus:call(
		'org.freedesktop.UDisks2',
		'/org/freedesktop/UDisks2/block_devices',
		'org.freedesktop.DBus.Introspectable',
		'Introspect',
		nil,
		nil,
		Gio.DBusConnectionFlags.NONE,
		-1,
		nil,
		function(conn, res)
			parse_block_devices(conn, res, callback)
		end
	)
	system_bus:call(
		'org.freedesktop.UDisks2',
		'/org/freedesktop/UDisks2',
		'org.freedesktop.DBus.ObjectManager',
		'GetManagedObjects',
		nil,
		nil,
		Gio.DBusConnectionFlags.NONE,
		-1,
		nil,
		function(conn, res)
			parse_devices(conn, res, callback)
		end
	)
end


local function register_listeners()
	system_bus:signal_subscribe(
		'org.freedesktop.UDisks2',
		'org.freedesktop.DBus.ObjectManager',
		'InterfacesAdded',
		nil,
		nil,
		Gio.DBusSignalFlags.NONE,
		function(conn, sender, path, interface_name, signal_name, user_data)
			rescan_devices()
		end
	)
	system_bus:signal_subscribe(
		'org.freedesktop.UDisks2',
		'org.freedesktop.DBus.ObjectManager',
		'InterfacesRemoved',
		nil,
		nil,
		Gio.DBusSignalFlags.NONE,
		function(conn, sender, path, interface_name, signal_name, user_data)
			rescan_devices()
		end
	)
	system_bus:signal_subscribe(
		'org.freedesktop.UDisks2',
		'org.freedesktop.DBus.Properties',
		'PropertiesChanged',
		nil,
		nil,
		Gio.DBusSignalFlags.NONE,
		function(conn, sender, path, interface_name, signal_name, user_data)
			rescan_devices()
		end
	)
	rescan_devices()
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
			register_listeners()
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
			stylesheet = 'svg { fill: '..beautiful.fg_normal..' }',
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
