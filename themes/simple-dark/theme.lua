--[[                                        ]]--
--                                            -
--       Inspired from WM 3.5.+ config        --
--        github.com/copycat-killer           --
--                                            -
--[[                                        ]]--

local xresources = require("beautiful.xresources")
--local xrdb = xresources.get_current_theme()
local dpi = xresources.apply_dpi
local gears = require("gears")
local surface = gears.surface
local cairo = require("lgi").cairo

theme = {}

themes_dir                                  = os.getenv("HOME") .. "/.config/awesome/themes/simple-dark"
theme.wallpaper                             = themes_dir .. "/wall.jpg"
theme.font                                  = "Ubuntu 9"
theme.clock_font                            = "UbuntuCondensed 9"
theme.volume_font                           = "UbuntuCondensed 9"
theme.battery_percent_font                  = "UbuntuCondensed 9"
theme.battery_current_font                  = "UbuntuCondensed 8"
theme.cpu_percent_font                      = "UbuntuCondensed 8"
theme.mem_percent_font                      = "UbuntuCondensed 8"
theme.temp_font                             = "UbuntuCondensed 8"
theme.process_font                          = "Ubuntu Mono 8"

theme.wibar_bg                              = "#2b2e32"
theme.fg_accent                             = "#ffffff"
theme.fg_normal                             = "#cccdcf"
theme.fg_secondary                          = "#88898c"
theme.fg_focus                              = "#A1D0D0"
theme.fg_urgent                             = "#CC9393"
theme.bg_normal                             = "#1A1A1AD0"
theme.bg_normal                             = "#1A1A1AD0"
theme.bg_focus                              = "#313131D0"
theme.bg_urgent                             = "#1A1A1A"
theme.bg_systray                            = theme.wibar_bg

theme.border_width                          = 1
theme.border_normal                         = "#3F3F3F"
theme.border_focus                          = "#7F7F7F"
theme.border_marked                         = "#CC9393"

theme.titlebar_bg_focus                     = "#313131D0"
theme.titlebar_bg_normal                    = "#1A1A1AD0"
theme.taglist_fg_focus                      = theme.fg_accent
theme.taglist_bg_focus                      = "#186dfe"
theme.taglist_bg_empty                      = "#00000020"
theme.taglist_bg_occupied                   = "#00000020"
theme.taglist_squares_sel                   = themes_dir .. "/icons/square_sel.svg"
theme.taglist_squares_unsel                 = themes_dir .. "/icons/square_unsel.svg"
theme.tasklist_bg_normal                    = "#2b2e3280"
theme.tasklist_bg_focus                     = "#186dfe20"
theme.tasklist_fg_normal                    = "#cccdcf"
theme.tasklist_fg_focus                     = "#cccdcf"
theme.tasklist_plain_task_name              = true

--local taglist_square_size = dpi(3)
--
--local function taglist_squares_sel()
--	local size = taglist_square_size
--	local img = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
--	local cr = cairo.Context(img)
--	cr:set_source(gears.color(theme.fg_normal))
--	cr:paint()
--	return img
--end
--theme.taglist_squares_sel = taglist_squares_sel()
--
--local function taglist_squares_unsel()
--	local size = taglist_square_size
--	local img = cairo.ImageSurface(cairo.Format.ARGB32, size, size)
--	local cr = cairo.Context(img)
--	cr:set_source(gears.color(theme.fg_normal))
--	cr:set_line_width(dpi(1))
--	cr:rectangle(0, 0, size, size)
--	cr:stroke()
--	return img
--end
--theme.taglist_squares_unsel = taglist_squares_unsel()

theme.textbox_widget_margin_top             = 1
theme.notify_fg                             = "#DCDCCC"
theme.notify_bg                             = theme.bg_normal
theme.notify_border                         = theme.border_focus
theme.awful_widget_height                   = 14
theme.awful_widget_margin_top               = 2
theme.mouse_finder_color                    = "#CC9393"
theme.menu_height                           = 20
theme.menu_width                            = 140
theme.menu_submenu_icon                     = themes_dir .. "/icons/submenu.svg"

theme.layout_tile                           = themes_dir .. "/icons/tile.svg"
theme.layout_tileleft                       = themes_dir .. "/icons/tileleft.svg"
theme.layout_tilebottom                     = themes_dir .. "/icons/tilebottom.svg"
theme.layout_tiletop                        = themes_dir .. "/icons/tiletop.svg"
theme.layout_fairv                          = themes_dir .. "/icons/fairv.svg"
theme.layout_fairh                          = themes_dir .. "/icons/fairh.svg"
theme.layout_spiral                         = themes_dir .. "/icons/spiral.svg"
theme.layout_dwindle                        = themes_dir .. "/icons/dwindle.svg"
theme.layout_max                            = themes_dir .. "/icons/max.svg"
theme.layout_fullscreen                     = themes_dir .. "/icons/fullscreen.svg"
theme.layout_magnifier                      = themes_dir .. "/icons/magnifier.svg"
theme.layout_floating                       = themes_dir .. "/icons/floating.svg"

theme.arrl                                  = themes_dir .. "/icons/arrl.png"
theme.arrl_dl                               = themes_dir .. "/icons/arrl_dl.png"
theme.arrl_ld                               = themes_dir .. "/icons/arrl_ld.png"

theme.widget_battery_full_bar               = {5, 7, 4, 7} -- top, right, bottom, left
theme.widget_battery_empty_bar              = {14, 7, 4, 7} -- top, right, bottom, left
theme.widget_battery                        = themes_dir .. "/icons/battery.svg"
theme.widget_wireless_chart                 = {60, 14, 2.5} -- angle, size, offset_top
theme.widget_mem                            = themes_dir .. "/icons/mem.svg"
theme.widget_cpu                            = themes_dir .. "/icons/cpu.svg"
theme.widget_temp                           = themes_dir .. "/icons/temp.svg"
theme.widget_net                            = themes_dir .. "/icons/net.png"
theme.widget_net_wireless                   = themes_dir .. "/icons/net_wireless.svg"
theme.widget_hdd                            = themes_dir .. "/icons/hdd.png"
theme.widget_vol_3                          = themes_dir .. "/icons/vol_3.svg"
theme.widget_vol_2                          = themes_dir .. "/icons/vol_2.svg"
theme.widget_vol_1                          = themes_dir .. "/icons/vol_1.svg"
theme.widget_vol_0                          = themes_dir .. "/icons/vol_0.svg"
theme.widget_vol_mute                       = themes_dir .. "/icons/vol_mute.svg"
theme.widget_vol_no                         = themes_dir .. "/icons/vol_no.svg"
theme.widget_mail                           = themes_dir .. "/icons/mail.png"
theme.widget_mail_notify                    = themes_dir .. "/icons/mail_notify.png"
theme.launch                                = themes_dir .. "/icons/launch.svg"

theme.removable_default_mounted             = themes_dir .. "/icons/removable_default_mounted.png"
theme.removable_default_unmounted           = themes_dir .. "/icons/removable_default_unmounted.png"
theme.removable_usb_mounted                 = themes_dir .. "/icons/removable_usb_mounted.png"
theme.removable_usb_unmounted               = themes_dir .. "/icons/removable_usb_unmounted.png"

theme.titlebar_close_button_focus               = themes_dir .. "/titlebar/close_focus.svg"
theme.titlebar_close_button_normal              = themes_dir .. "/titlebar/close_normal.svg"

theme.titlebar_ontop_button_focus_active        = themes_dir .. "/titlebar/ontop_focus_active.svg"
theme.titlebar_ontop_button_normal_active       = themes_dir .. "/titlebar/ontop_normal_active.svg"
theme.titlebar_ontop_button_focus_inactive      = themes_dir .. "/titlebar/ontop_focus_inactive.svg"
theme.titlebar_ontop_button_normal_inactive     = themes_dir .. "/titlebar/ontop_normal_inactive.svg"

theme.titlebar_sticky_button_focus_active       = themes_dir .. "/titlebar/sticky_focus_active.svg"
theme.titlebar_sticky_button_normal_active      = themes_dir .. "/titlebar/sticky_normal_active.svg"
theme.titlebar_sticky_button_focus_inactive     = themes_dir .. "/titlebar/sticky_focus_inactive.svg"
theme.titlebar_sticky_button_normal_inactive    = themes_dir .. "/titlebar/sticky_normal_inactive.svg"

theme.titlebar_floating_button_focus_active     = themes_dir .. "/titlebar/floating_focus_active.svg"
theme.titlebar_floating_button_normal_active    = themes_dir .. "/titlebar/floating_normal_active.svg"
theme.titlebar_floating_button_focus_inactive   = themes_dir .. "/titlebar/floating_focus_inactive.svg"
theme.titlebar_floating_button_normal_inactive  = themes_dir .. "/titlebar/floating_normal_inactive.svg"

theme.titlebar_maximized_button_focus_active    = themes_dir .. "/titlebar/maximized_focus_active.svg"
theme.titlebar_maximized_button_normal_active   = themes_dir .. "/titlebar/maximized_normal_active.svg"
theme.titlebar_maximized_button_focus_inactive  = themes_dir .. "/titlebar/maximized_focus_inactive.svg"
theme.titlebar_maximized_button_normal_inactive = themes_dir .. "/titlebar/maximized_normal_inactive.svg"

theme.titlebar_minimize_button_focus_active    = themes_dir .. "/titlebar/minimize_focus_active.svg"
theme.titlebar_minimize_button_normal_active   = themes_dir .. "/titlebar/minimize_normal_active.svg"
theme.titlebar_minimize_button_focus_inactive  = themes_dir .. "/titlebar/minimize_focus_inactive.svg"
theme.titlebar_minimize_button_normal_inactive = themes_dir .. "/titlebar/minimize_normal_inactive.svg"

--theme.tasklist_floating                     = ""
--theme.tasklist_maximized_horizontal         = ""
--theme.tasklist_maximized_vertical           = ""

return theme
