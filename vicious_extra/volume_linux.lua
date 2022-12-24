local helpers = require("vicious.helpers")

local volume_value = 0.0;
local volume_mute = false;

worker = helpers.setcall(function (format, warg)
	local status = {
		value = volume_value,
		mute = volume_mute
	}

	return status
end)

worker.set_volume = function(value, mute)
	volume_value = value
	volume_mute = mute
end

return worker
