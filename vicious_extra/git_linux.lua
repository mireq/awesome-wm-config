local helpers = require("vicious.helpers")
local utils = require("utils")

local gdebug = require("gears.debug")
local tool = utils.get_config_dir() .. "tools/get_repository_stats"

-- cache variables
local cache = {
	value = nil,
	timestamp = 0
}
local CACHE_TIMEOUT = 60 -- seconds

return helpers.setcall(function (format)
	local status = {
		text = ''
	}

	local now = os.time()
	if not cache.value or (now - cache.timestamp) > CACHE_TIMEOUT then
		local handle = io.popen(tool)
		if handle then
			local output = handle:read("*a")
			handle:close()
			cache.value = output or ''
			cache.timestamp = now
		else
			cache.value = ''
		end
	end

	if cache.value then
		local added, removed, files = string.match(cache.value, "%+(%d+)%s+%-(%d+)%s+F(%d+)")
		if added == nil then
			status.text = ''
		else
			status.text = '<span color="#40f030">+</span>' .. added .. ' <span color="#f08080">-</span>' .. removed .. ' <span color="#f0f080">•</span>' .. files
		end
	else
		status.text = ''
	end
	return status
end)
