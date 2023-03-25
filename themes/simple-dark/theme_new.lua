theme = {}

themes_dir = os.getenv("HOME") .. "/.config/awesome/themes/simple-dark"

theme.wallpaper                             = themes_dir .. "/wall_tmb.jpg"

theme.font                                  = "Ubuntu 9"
theme.sensor_font                           = "UbuntuCondensed 8"
theme.border_width                          = 1
theme.border_normal                         = "#2b2e32"
theme.border_focus                          = "#7f7f7f"
theme.border_color_normal                   = "#2b2e32"
theme.border_color_focus                    = "#7f7f7f"
theme.border_color_active                   = "#4069a7"
theme.border_color_urgent                   = "#d43535"

theme.titlebar_bg_focus                     = "#31507f"
theme.titlebar_bg_normal                    = "#2b2e32"
theme.titlebar_bg_urgent                    = "#d43535"

theme.wibar_bg                              = "#2b2e32f8"
theme.wibar_bg_bottom                       = "#282a2ef8"
theme.wibar_border_bottom                   = "#111214f8"
--theme.wibar_border_top                    = "#565c64c0"
theme.fg_accent                             = "#ffffff"
theme.fg_normal                             = "#cccdcf"
theme.fg_secondary                          = "#88898c"
theme.fg_focus                              = "#ffffff"
theme.fg_urgent                             = "#ffffff"
theme.bg_normal                             = "#222528"
theme.bg_focus                              = "#186dfe"
--theme.bg_urgent                             = "#1A1A1A"
theme.bg_urgent                             = "#d43535"
theme.bg_systray                            = theme.wibar_bg

theme.process_font                          = "Ubuntu Mono 8"
theme.widget_temp                           = themes_dir .. "/icons/temp.svg"
theme.widget_mem                            = themes_dir .. "/icons/mem.svg"
theme.widget_cpu                            = themes_dir .. "/icons/cpu.svg"
theme.widget_wireless                       = themes_dir .. "/icons/net_wireless_"
theme.widget_wireless_count                 = 4
theme.widget_volume                         = themes_dir .. "/icons/volume_"
theme.widget_volume_count                   = 3
theme.widget_battery_full_bar               = {5, 9, 14, 7} -- top, right, bottom, left
theme.widget_battery_empty_bar              = {14, 9, 14, 7} -- top, right, bottom, left
theme.widget_battery                        = themes_dir .. "/icons/battery.svg"

theme.launch                                = themes_dir .. "/icons/launch.svg"

theme.menu_height                           = 20
theme.menu_width                            = 140
theme.menu_submenu_icon                     = themes_dir .. "/icons/submenu.svg"
theme.menu_border_width                     = 0
theme.menu_fg_focus                         = '#ffffff'

theme.taglist_fg_focus                      = '#00000000'
theme.taglist_fg_urgent                     = '#00000000'
theme.taglist_fg_occupied                   = '#00000000'
theme.taglist_fg_empty                      = '#00000000'
theme.taglist_fg_volatile                   = '#00000000'
theme.taglist_bg_focus                      = theme.bg_focus
theme.taglist_bg_empty                      = "#00000080"
theme.taglist_bg_occupied                   = "#00000080"
theme.taglist_squares_sel                   = themes_dir .. "/icons/square_sel.svg"
theme.taglist_squares_unsel                 = themes_dir .. "/icons/square_unsel.svg"

theme.tasklist_bg_normal                    = '#00000000'
theme.tasklist_bg_focus                     = theme.bg_focus
theme.tasklist_fg_normal                    = "#8a8b8f"
theme.tasklist_fg_focus                     = theme.fg_focus
theme.tasklist_bg_opacity                   = 0.2
theme.tasklist_icon_opacity_normal          = 0.5
theme.tasklist_icon_opacity_focus           = 1
--theme.tasklist_fg_focus                   = "#A1D0D0"
theme.tasklist_font_focus                   = "Ubuntu Bold 9"

theme.notify_fg                             = theme.fg_normal
theme.notify_bg                             = theme.bg_normal
--theme.notify_border                       = '#2b2e32'
theme.notify_border                         = theme.border_focus

theme.tooltip_bg                            = theme.bg_normal
theme.tooltip_fg                            = theme.fg_normal
theme.tooltip_border_width                  = 1
theme.tooltip_font                          = theme.font
theme.tooltip_border_color                  = theme.border_focus

theme.notification_bg                       = theme.bg_normal
theme.notification_fg                       = theme.fg_normal
theme.notification_border_color             = theme.border_focus

theme.hotkeys_bg                            = theme.bg_normal
theme.hotkeys_border_color                  = theme.border_focus
theme.hotkeys_fg                            = theme.fg_normal
theme.hotkeys_modifiers_fg                  = theme.fg_secondary
theme.hotkeys_font                          = "Ubuntu Mono Bold 8"
theme.hotkeys_description_font              = "Ubuntu Mono 8"
theme.hotkeys_group_margin                  = 6

theme.udisks_storage                        = themes_dir .. "/icons/storage.svg"
theme.udisks_thumb                          = themes_dir .. "/icons/thumb.svg"
theme.udisks_umounted_opacity               = 0.5

theme.cyclefocus_margin                     = 0

theme.titlebar_position                     = 'top'

return theme
