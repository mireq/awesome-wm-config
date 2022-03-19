local helpers = require("vicious.helpers")

local gdebug = require("gears.debug")

return helpers.setcall(function (format)
	local status = {
		link_quality = 0.0
	}

	local wireless_stats = io.open('/proc/net/wireless', 'r')
	if wireless_stats ~= nil then
		for line in wireless_stats:lines() do
			local _, _, iface, _, link = string.find(line, "^(.*):%s*(%d+)%s+([0-9.]+)")
			if iface ~= nil then
				status.link_quality = tonumber(link) / 100.0;
			end
		end
		wireless_stats.close()
	end

	return status
end)
