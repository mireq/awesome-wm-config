theme = {}

themes_dir = os.getenv("HOME") .. "/.config/awesome/themes/simple-dark"

theme.wallpaper = themes_dir .. "/wall_tmb.jpg"
theme.wibar_bg = "#2b2e32c0"
theme.wibar_bg_bottom = "#222528c0"
theme.wibar_border_bottom = "#111214c0"
theme.wibar_border_top = "#565c64c0"

theme.launch = themes_dir .. "/icons/launch.svg"

theme.menu_height = 20
theme.menu_width = 140
theme.menu_submenu_icon = themes_dir .. "/icons/submenu.svg"

return theme
