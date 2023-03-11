theme = {}

themes_dir = os.getenv("HOME") .. "/.config/awesome/themes/simple-dark"

theme.wallpaper                             = themes_dir .. "/wall_tmb.jpg"

theme.font                                  = "Ubuntu 9"
theme.border_width                          = 1
theme.border_normal                         = "#2b2e32"
theme.border_focus                          = "#7f7f7f"

theme.wibar_bg                              = "#2b2e32f8"
theme.wibar_bg_bottom                       = "#282a2ef8"
theme.wibar_border_bottom                   = "#111214f8"
--theme.wibar_border_top                    = "#565c64c0"
theme.fg_accent                             = "#ffffff"
theme.fg_normal                             = "#cccdcf"
theme.fg_secondary                          = "#88898c"
theme.fg_focus                              = "#ffffff"
theme.fg_urgent                             = "#CC9393"
theme.bg_normal                             = "#222528"
theme.bg_focus                              = "#186dfe"
theme.bg_urgent                             = "#1A1A1A"
theme.bg_systray                            = theme.wibar_bg

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
theme.taglist_bg_focus                      = "#186dfe"
theme.taglist_bg_empty                      = "#00000080"
theme.taglist_bg_occupied                   = "#00000080"
theme.taglist_squares_sel                   = themes_dir .. "/icons/square_sel.svg"
theme.taglist_squares_unsel                 = themes_dir .. "/icons/square_unsel.svg"

theme.tasklist_bg_normal                    = '#00000000'
theme.tasklist_bg_focus                     = '#00000000'
theme.tasklist_fg_normal                    = "#8a8b8f"
theme.tasklist_fg_focus                     = "#cccdcf"
--theme.tasklist_fg_focus                   = "#A1D0D0"
theme.tasklist_font_focus                   = "Ubuntu Bold 9"

theme.notify_fg                             = theme.fg_normal
theme.notify_bg                             = theme.bg_normal
--theme.notify_border                       = '#2b2e32'
theme.notify_border                         = theme.border_focus

theme.hotkeys_bg                            = theme.bg_normal
theme.hotkeys_border_color                  = theme.notify_border
theme.hotkeys_fg                            = theme.fg_normal
theme.hotkeys_modifiers_fg                  = theme.fg_secondary
theme.hotkeys_font                          = "Ubuntu Mono Bold 8"
theme.hotkeys_description_font              = "Ubuntu Mono 8"
theme.hotkeys_group_margin                  = 6

return theme
