theme = {}

themes_dir = os.getenv("HOME") .. "/.config/awesome/themes/simple-dark"

theme.wallpaper                             = themes_dir .. "/wall_tmb.jpg"

theme.font                                  = "Ubuntu 9"

theme.wibar_bg                              = "#2b2e32f8"
theme.wibar_bg_bottom                       = "#282a2ef8"
theme.wibar_border_bottom                   = "#111214f8"
--theme.wibar_border_top                    = "#565c64c0"
theme.fg_accent                             = "#ffffff"
theme.fg_normal                             = "#cccdcf"
theme.fg_secondary                          = "#88898c"
theme.fg_focus                              = "#A1D0D0"
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

theme.taglist_fg_focus                      = '#00000000'
theme.taglist_fg_urgent                     = '#00000000'
theme.taglist_fg_occupied                   = '#00000000'
theme.taglist_fg_empty                      = '#00000000'
theme.taglist_fg_volatile                   = '#00000000'
theme.taglist_bg_focus                      = "#186dfe"
theme.taglist_bg_empty                      = "#00000040"
theme.taglist_bg_occupied                   = "#00000040"
theme.taglist_squares_sel                   = themes_dir .. "/icons/square_sel.svg"
theme.taglist_squares_unsel                 = themes_dir .. "/icons/square_unsel.svg"

return theme
