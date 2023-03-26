local naughty = require("naughty")
local os = require("os")
local awful = require("awful")
local string = require("string")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local module = {};

local function colorize(string, pattern, color)
  
	local mystring=""
	mystring=string.gsub(string,pattern,'<span color="'..color..'">%1</span>')
	return mystring
end

local processpopup = nil
local processpopup_visible = false
local processstats = nil
local proc_offset = 25

local function hide_process_info()
  if processpopup ~= nil then
    naughty.destroy(processpopup)
    processpopup = nil
    proc_offset = 25
  end
end
local function show_process_info(inc_proc_offset, title_color,user_color, root_color)
  local save_proc_offset = proc_offset
	hide_process_info()
	proc_offset = save_proc_offset + inc_proc_offset
	awful.spawn.easy_async_with_shell('/bin/ps --sort -c,-s -eo fname,user,%cpu,%mem,pid,gid,ppid,tname,label | /usr/bin/head -n '..proc_offset, function(stdout, stderr, exitreason, exitsignal)
		processstats = stdout
		processstats = colorize(processstats, "COMMAND", title_color)
		processstats = colorize(processstats, "USER", title_color)
		processstats = colorize(processstats, "%%CPU", title_color)
		processstats = colorize(processstats, "%%MEM", title_color)
		processstats = colorize(processstats, " PID", title_color)
		processstats = colorize(processstats, "GID", title_color)
		processstats = colorize(processstats, "PPID", title_color)
		processstats = colorize(processstats, "TTY", title_color)
		processstats = colorize(processstats, "LABEL", title_color)
		processstats = colorize(processstats, "root", root_color)
		processstats = colorize(processstats, os.getenv("USER"), user_color)
		if processpopup_visible then
			processpopup = naughty.notify({
				text = '<span font="'..(beautiful.process_font)..'" color="'..(beautiful.notify_fg or beautiful.fg_normal)..'">'..processstats..'</span>',
				timeout = 0, hover_timeout = 0.5, border_width = dpi(1, awful.screen.focused())
			})
		end
	end)
end
---Top popup.
--It binds a colorized output of the top command to a widget, and the possibility to launch htop with a click on the widget.
--</br>Example blingbling.popups.htop(mycairograph,{ title_color = "#rrggbbaa", user_color    = "#rrggbbaa", root_color="#rrggbbaa", terminal = "urxvt"})
--</br>The terminal parameter is not mandatory, htop will be launch in xterm. Mandatory arguments:
-- <ul> <li>title_color define the color of the title's columns.</li>
--  <li>user_color display the name of the current user with this color in the top output.</li>
--  <li>root_color display the root name with this color in the top output. </li></ul>
--@param mywidget the widget
--@param args a table of arguments { title_color = "#rrggbbaa", user_color = "#rrggbbaa", root_color="#rrggbbaa", terminal = a terminal name})
function htop(mywidget, args)
  local args = args or {}
  mywidget:connect_signal("mouse::enter", function()
    processpopup_visible = true
    show_process_info(0,  args["title_color"] or superproperties.htop_title_color,
                          args["user_color"] or superproperties.htop_user_color,
                          args["root_color"] or superproperties.htop_root_color)
  end)
  mywidget:connect_signal("mouse::leave", function()
    processpopup_visible = false
    hide_process_info()
  end)

mywidget:buttons(awful.util.table.join(
  awful.button({ }, 4, function()
    show_process_info(-1,  args["title_color"] or superproperties.htop_title_color,
                           args["user_color"] or superproperties.htop_user_color,
                           args["root_color"] or superproperties.htop_root_color)
  end),
  awful.button({ }, 5, function()
    show_process_info(1, args["title_color"] or superproperties.htop_title_color,
                         args["user_color"] or superproperties.htop_user_color,
                         args["root_color"] or superproperties.htop_root_color)
  end),
   awful.button({ }, 1, function()
    if args["terminal"] then
      awful.spawn.with_shell(args["terminal"] .. " -e htop")
    else
      awful.spawn.with_shell("xterm" .. " -e htop")
    end
  end)
  ))
end


local netpopup = nil
local netpopup_visible = false

local function hide_netinfo()
	if netpopup ~= nil then
		naughty.destroy(netpopup)
		netpopup = nil
	end
end

local function show_netinfo(my_title_color, my_established_color, my_listen_color)
	hide_netinfo()
	awful.spawn.easy_async_with_shell('/bin/netstat -pa -u -t | grep -v TIME_WAIT'..proc_offset, function(stdout, stderr, exitreason, exitsignal)
		local str = stdout
		str=colorize(str,"Proto", my_title_color)
		str=colorize(str,'Recv%XQ', my_title_color)
		str=colorize(str,"Send%XQ", my_title_color)
		str=colorize(str,"Local Address", my_title_color)
		str=colorize(str,"Foreign Address", my_title_color)
		str=colorize(str,"State", my_title_color)
		str=colorize(str,'PID/Program name', my_title_color)
		str=colorize(str,"Security Context", my_title_color)
		str=colorize(str,"ESTABLISHED", my_established_color)
		str=colorize(str,"LISTEN", my_listen_color)
		if netpopup_visible then
			netpopup = naughty.notify({
				text = '<span font="'..beautiful.process_font..'">'..str..'</span>',
				timeout = 0, hover_timeout = 0.5, border_width = dpi(1, awful.screen.focused())
			})
		end
	end)
end

---Netstat popup.
--It binds a colorized output of the netstat command to a widget.
--</br>Example: blingbling.popups.netstat(net,{ title_color = "#rrggbbaa", established_color= "#rrggbbaa", listen_color="#rrggbbaa"})
--</br>Mandatory arguments:
--<ul><li>widget (if blinbling widget add .widget ex: cpu.widget, if textbox or image box just put the widget name)</li>
--<li>title_color define the color of the title's columns.</li>
--<li>established_color display the state "ESTABLISHED" of a connexion  with this color in the netstat output.</li>
--<li>listen_color display the state "LISTEN" with this color in the netstat output.</li></ul>
--@param mywidget the widget
--@param args a table { title_color = "#rrggbbaa", established_color= "#rrggbbaa", listen_color="#rrggbbaa"}
function netstat(mywidget, args)
  local args = args or {}
  mywidget:connect_signal("mouse::enter", function()
    netpopup_visible = true
    show_netinfo( args["title_color"] or superproperties.netstat_title_color,
                  args["established_color"] or superproperties.netstat_established_color,
                  args["listen_color"] or superproperties.netstat_listen_color)
  end)
  mywidget:connect_signal("mouse::leave", function()
    netpopup_visible = false
    hide_netinfo()
  end)
end


module.htop = htop
module.netstat = netstat
return module
