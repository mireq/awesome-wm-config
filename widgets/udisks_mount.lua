local wibox = require("wibox")
local base = require("wibox.widget.base")
local common = require("awful.widget.common")
local gtable = require("gears.table")
local fixed = require("wibox.layout.fixed")
local gdebug = require("gears.debug")
local beautiful = require("beautiful")


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
	gdebug.dump(data)

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
	local ret = base.make_widget(nil, nil, {
		enable_properties = true,
	})

	gtable.crush(ret, udisks_mount_widget, true)

	print(args.screen)
	local screen = get_screen(args.screen)

	ret._private.screen = screen
	ret._private.base_layout = fixed.horizontal()
	print(screen)

	local data = setmetatable({"a", "b"}, { __mode = 'k' })
	local uf = common.list_update;

	widget_update(ret._private.screen, ret, ret._private.buttons, ret._private.filter, data, args.style, uf, args)

	gtable.crush(ret, udisks_mount_widget, true)

	return ret
end

function udisks_mount_widget.mt:__call(...)
	print("new")
	return new(...)
end


return setmetatable(udisks_mount_widget, udisks_mount_widget.mt)
