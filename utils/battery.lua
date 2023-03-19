local home = os.getenv("HOME")
local history_filename = home .. '/.battery_history'

local battery_history_file = io.open(history_filename, 'r')
if battery_history_file ~= nil then
	battery_history_file:close()
	battery_history_file = io.open(history_filename, 'a')
end
local proc_stat = io.open('/proc/stat', 'r')

local M = {}

function M.record(device)
	if battery_history_file ~= nil and proc_stat ~= nil then
		local status = nil
		if device.status == "Charging" then
			status = 'c'
		elseif device.status == "Discharging" then
			status = 'd'
		end

		if status == nil then
			return
		end

		proc_stat:seek("set", 0)
		local cpuline = '';
		for line in proc_stat:lines() do
			local _, _, cpu, user, nice, system, idle, iowait, irq, softirq = string.find(line, "^cpu([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)")
			if cpu ~= nil then
				if cpu ~= '0' then
					cpuline = cpuline .. ' '
				end
				cpuline = cpuline .. user .. ',' .. nice .. ',' .. system .. ',' .. idle .. ',' .. iowait .. ',' .. irq .. ',' .. softirq
			end
		end

		if cpuline then
			cpuline = ';' .. cpuline
		end

		local time = os.time()
		battery_history_file:write(status .. ";" .. time .. ";" .. math.floor(device.power_now * 1000000) .. ";" .. math.floor(device.energy_now * 1000000) .. ";" .. math.floor(device.voltage_now * 1000000) .. cpuline .. "\n")
		battery_history_file:flush()
	end
end

return M
