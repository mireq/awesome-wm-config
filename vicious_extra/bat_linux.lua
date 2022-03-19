local helpers = require("vicious.helpers")

return helpers.setcall(function (format, warg)
	if not warg then return end

	local battery = helpers.pathtotable("/sys/class/power_supply/"..warg)

	local status = {
		status = "Unknown",
		power_now = nil,
		voltage_now = nil,
		energy_now = nil,
		energy_full = nil,
		energy_full_design = nil,
		percentage = nil,
		percentage_exact = nil,
		wear_percentage = nil,
		wear_percentage_exact = nil,
		remaining_seconds = nil,
		time = "N/A",
	}

	if battery.present ~= "1\n" then
		return status
	end

	status.status = battery.status:gsub("\n", "")

	if battery.power_now then
		status.power_now = tonumber(battery.power_now) / 1000000
	end

	if battery.voltage_now then
		status.voltage_now = tonumber(battery.voltage_now) / 1000000
	end

	if battery.energy_now then
		status.energy_now = tonumber(battery.energy_now) / 1000000
	end

	if battery.energy_full then
		status.energy_full = tonumber(battery.energy_full) / 1000000
	end

	if battery.energy_full_design then
		status.energy_full_design = tonumber(battery.energy_full_design) / 1000000
	end

	if status.energy_full then
		status.percentage_exact = math.min(status.energy_now / status.energy_full * 100)
		status.percentage = math.floor(status.percentage_exact)
	end

	if status.energy_full and status.energy_full_design then
		status.wear_percentage_exact = math.min(status.energy_full / status.energy_full_design * 100)
		status.wear_percentage = math.floor(status.wear_percentage_exact)
	end

	local hours_left = nil
	if status.power_now and status.energy_full and status.energy_now and status.power_now > 0 then
		if status.status == 'Charging' then
			hours_left = (status.energy_full - status.energy_now) / status.power_now
		elseif status.status == 'Discharging' then
			hours_left = status.energy_now / status.power_now
		end
	end

	if hours_left then
		status.remaining_seconds = math.floor(hours_left * 3600)
		local hours_round = math.floor(hours_left)
		status.time = string.format("%d:%02d", hours_round, math.floor((hours_left - hours_round) * 60))
	end


	return status
end)
