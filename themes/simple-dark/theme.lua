theme = {}

themes_dir = os.getenv("HOME") .. "/.config/awesome/themes/simple-dark"

theme.wallpaper                             = themes_dir .. "/wall_1.jpg"

theme.font                                  = "Ubuntu 9"
theme.sensor_font                           = "UbuntuCondensed 9"
theme.battery_current_font                  = "UbuntuCondensed 8"
theme.temp_font                             = "UbuntuCondensed 8"
theme.mem_font                              = "UbuntuCondensed 8"
theme.cpu_font                              = "UbuntuCondensed 8"
theme.border_width                          = 1
--theme.border_normal                       = "#2b2e32"
--theme.border_focus                        = "#7f7f7f"
theme.border_focus                          = "#2b2e32"
theme.border_color_normal                   = "#2b2e32"
theme.border_color_focus                    = "#7f7f7f"
theme.border_color_active                   = "#7f7f7f"
--theme.border_color_active                 = "#7f7f7f"
theme.border_color                          = "#ff0000"
theme.border_color_urgent                   = "#d43535"

theme.wibar_bg                              = "#2b2e32f8"
theme.wibar_bg_bottom                       = "#282a2ef8"
theme.wibar_border_bottom                   = "#212326f8"
theme.wibar_border_top                      = "#565c64c0"
theme.fg_accent                             = "#ffffff"
theme.fg_normal                             = "#cccdcf"
theme.fg_secondary                          = "#88898c"
theme.fg_inactive                           = "#88898c"
theme.fg_focus                              = "#ffffff"
theme.fg_urgent                             = "#ffffff"
theme.bg_normal                             = "#222528"
theme.bg_focus                              = "#186dfe"
--theme.bg_urgent                             = "#1A1A1A"
theme.bg_urgent                             = "#d43535"
theme.bg_systray                            = theme.wibar_bg


-- {{{ Layout
theme.layout_stylesheet                     = 'svg { color: ' .. theme.fg_normal .. '; }'
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
-- }}}

theme.process_font                          = "Ubuntu Mono 8"
theme.widget_temp                           = themes_dir .. "/icons/temp_small.svg"
theme.widget_mem                            = themes_dir .. "/icons/mem.svg"
theme.widget_cpu                            = themes_dir .. "/icons/cpu.svg"
theme.widget_wireless                       = themes_dir .. "/icons/net_wireless_"
theme.widget_wireless_count                 = 4
theme.widget_volume                         = themes_dir .. "/icons/volume_"
theme.widget_volume_count                   = 3
theme.widget_battery_full_bar               = {7, 7, 13, 5} -- top, right, bottom, left
theme.widget_battery_empty_bar              = {13, 7, 13, 5} -- top, right, bottom, left
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
theme.udisks_usb                            = themes_dir .. "/icons/thumb.svg"
theme.udisks_opacity                        = 0.5
theme.udisks_opacity_mounted                = 1.0

-- {{{ Titlebar
theme.titlebar_bg_urgent                    = "#d43535"
theme.titlebar_bg_focus                     = "#2b2e32f0"
theme.titlebar_bg_normal                    = "#3c4046"
theme.titlebar_fg_normal                    = theme.fg_inactive
theme.titlebar_fg_focus                     = theme.fg_normal
theme.titlebar_fg_urgent                    = theme.fg_accent
--theme.titlebar_bg_focus                   = "#313131D0"
--theme.titlebar_bg_normal                  = "#1A1A1AD0"
theme.titlebar_position                     = 'right'

theme.titlebar_close_button_focus                        = themes_dir .. "/titlebar/close.svg"
theme.titlebar_close_button_normal                       = themes_dir .. "/titlebar/close.svg"
theme.titlebar_close_button_normal_hover                 = themes_dir .. "/titlebar/close_hover.svg"
theme.titlebar_close_button_focus_hover                  = themes_dir .. "/titlebar/close_hover.svg"
theme.titlebar_maximized_button_inactive                 = themes_dir .. "/titlebar/maximized.svg"
theme.titlebar_maximized_button_active                   = themes_dir .. "/titlebar/maximized.svg"
theme.titlebar_maximized_button_active_hover             = themes_dir .. "/titlebar/maximized_hover.svg"
theme.titlebar_maximized_button_inactive_hover           = themes_dir .. "/titlebar/maximized_hover.svg"
theme.titlebar_maximized_button_focus_active_hover       = themes_dir .. "/titlebar/maximized_hover.svg"
theme.titlebar_maximized_button_focus_inactive_hover     = themes_dir .. "/titlebar/maximized_hover.svg"

theme.titlebar_minimize_button_focus                     = themes_dir .. "/titlebar/minimize.svg"
theme.titlebar_minimize_button_normal                    = themes_dir .. "/titlebar/minimize.svg"
theme.titlebar_minimize_button_inactive                  = themes_dir .. "/titlebar/minimize.svg"
theme.titlebar_minimize_button_active                    = themes_dir .. "/titlebar/minimize.svg"
theme.titlebar_minimize_button_active_hover              = themes_dir .. "/titlebar/minimize_hover.svg"
theme.titlebar_minimize_button_inactive_hover            = themes_dir .. "/titlebar/minimize_hover.svg"
theme.titlebar_minimize_button_focus_hover               = themes_dir .. "/titlebar/minimize_hover.svg"
theme.titlebar_minimize_button_normal_hover              = themes_dir .. "/titlebar/minimize_hover.svg"
theme.titlebar_minimize_button_focus_active_hover        = themes_dir .. "/titlebar/minimize_hover.svg"
theme.titlebar_minimize_button_focus_inactive_hover      = themes_dir .. "/titlebar/minimize_hover.svg"

theme.titlebar_ontop_button_focus                        = themes_dir .. "/titlebar/ontop.svg"
theme.titlebar_ontop_button_normal                       = themes_dir .. "/titlebar/ontop.svg"
theme.titlebar_ontop_button_inactive                     = themes_dir .. "/titlebar/ontop.svg"
theme.titlebar_ontop_button_active                       = themes_dir .. "/titlebar/ontop.svg"
theme.titlebar_ontop_button_active_hover                 = themes_dir .. "/titlebar/ontop_hover.svg"
theme.titlebar_ontop_button_inactive_hover               = themes_dir .. "/titlebar/ontop_hover.svg"
theme.titlebar_ontop_button_focus_hover                  = themes_dir .. "/titlebar/ontop_hover.svg"
theme.titlebar_ontop_button_normal_hover                 = themes_dir .. "/titlebar/ontop_hover.svg"
theme.titlebar_ontop_button_focus_active_hover           = themes_dir .. "/titlebar/ontop_hover.svg"
theme.titlebar_ontop_button_focus_inactive_hover         = themes_dir .. "/titlebar/ontop_hover.svg"

theme.titlebar_sticky_button_focus                       = themes_dir .. "/titlebar/sticky.svg"
theme.titlebar_sticky_button_normal                      = themes_dir .. "/titlebar/sticky.svg"
theme.titlebar_sticky_button_inactive                    = themes_dir .. "/titlebar/sticky.svg"
theme.titlebar_sticky_button_active                      = themes_dir .. "/titlebar/sticky.svg"
theme.titlebar_sticky_button_active_hover                = themes_dir .. "/titlebar/sticky_hover.svg"
theme.titlebar_sticky_button_inactive_hover              = themes_dir .. "/titlebar/sticky_hover.svg"
theme.titlebar_sticky_button_focus_hover                 = themes_dir .. "/titlebar/sticky_hover.svg"
theme.titlebar_sticky_button_normal_hover                = themes_dir .. "/titlebar/sticky_hover.svg"
theme.titlebar_sticky_button_focus_active_hover          = themes_dir .. "/titlebar/sticky_hover.svg"
theme.titlebar_sticky_button_focus_inactive_hover        = themes_dir .. "/titlebar/sticky_hover.svg"

theme.titlebar_floating_button_focus                     = themes_dir .. "/titlebar/floating.svg"
theme.titlebar_floating_button_normal                    = themes_dir .. "/titlebar/floating.svg"
theme.titlebar_floating_button_inactive                  = themes_dir .. "/titlebar/floating.svg"
theme.titlebar_floating_button_active                    = themes_dir .. "/titlebar/floating.svg"
theme.titlebar_floating_button_active_hover              = themes_dir .. "/titlebar/floating_hover.svg"
theme.titlebar_floating_button_inactive_hover            = themes_dir .. "/titlebar/floating_hover.svg"
theme.titlebar_floating_button_focus_hover               = themes_dir .. "/titlebar/floating_hover.svg"
theme.titlebar_floating_button_normal_hover              = themes_dir .. "/titlebar/floating_hover.svg"
theme.titlebar_floating_button_focus_active_hover        = themes_dir .. "/titlebar/floating_hover.svg"
theme.titlebar_floating_button_focus_inactive_hover      = themes_dir .. "/titlebar/floating_hover.svg"
-- }}}

theme.cyclefocus_margin                     = 0

return theme
