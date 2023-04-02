local awful = require("awful")
local gears = require("gears")
local utils = require("utils.utility")
local lgi = require("lgi")
local Gio = lgi.Gio

local capi = {
	awesome = awesome,
}

local M = gears.object()


local function with_line_callback_stdin(cmd, callbacks)
	local stdout_callback, stderr_callback, done_callback, exit_callback = callbacks.stdout, callbacks.stderr, callbacks.output_done, callbacks.exit
	local have_stdout, have_stderr = stdout_callback ~= nil, stderr_callback ~= nil
	local pid, _, stdin, stdout, stderr = capi.awesome.spawn(cmd, false, true, have_stdout, have_stderr, exit_callback)
	if type(pid) == "string" then
		-- Error
		return pid
	end

	local done_before = false
	local function step_done()
		if have_stdout and have_stderr and not done_before then
			done_before = true
			return
		end
		if done_callback then
			done_callback()
		end
	end
	if have_stdout then
		awful.spawn.read_lines(Gio.UnixInputStream.new(stdout, true), stdout_callback, step_done, true)
	end
	if have_stderr then
		awful.spawn.read_lines(Gio.UnixInputStream.new(stderr, true), stderr_callback, step_done, true)
	end
	if callbacks.stdin then
		callbacks.stdin(Gio.UnixOutputStream.new(stdin, true), pid);
	end
	return pid
end

local volume_monitor_ctl = nil
local volume_monitor_pid = nil

local function volume_monitor_write(cmd)
	if volume_monitor_ctl ~= nil then
		volume_monitor_ctl:write_all(cmd .. '\n')
		volume_monitor_ctl:flush()
	end
end

local function on_volume_line(line)
	local found, __, mute_flag, volume = string.find(line, "^volume sink\t[*](.)\t([0-9.]+)\t.*$")
	if found ~= nil then
		local volume_value = tonumber(volume);
		local volume_mute
		if mute_flag == "M" then
			volume_mute = true
		else
			volume_mute = false
		end

		M:emit_signal('master_sink_changed', { volume = volume_value, mute = volume_mute })
	end
end

function M.start_monitor()
	M.stop_monitor()
	volume_monitor_pid = with_line_callback_stdin('stdbuf -oL ' .. utils.get_config_dir() .. 'pulsectrl', {
		stdout = function(line)
			on_volume_line(line)
		end,
		exit = function()
			volume_monitor_pid = nil;
		end,
		stdin = function(stdin, pid)
			if stdin ~= nil then
				volume_monitor_ctl = stdin
			end
		end,
	})
end

function M.stop_monitor()
	if volume_monitor_pid then
		if volume_monitor_ctl ~= nil then
			volume_monitor_ctl:close()
			volume_monitor_ctl = nil
		end
		if volume_monitor_pid ~= nil then
			awesome.kill(volume_monitor_pid, awesome.unix_signal.SIGTERM)
			volume_monitor_pid = nil
		end
	end
end

function M.sink_change(val)
	volume_monitor_write('sink change ' .. tostring(val))
end

function M.source_change(val)
	volume_monitor_write('source change ' .. tostring(val))
end

function M.sink_mute_toggle()
	volume_monitor_write('sink mute_toggle')
end

function M.source_mute_toggle()
	volume_monitor_write('source mute_toggle')
end

awesome.connect_signal("exit", function()
	M.stop_monitor()
end)

return M
