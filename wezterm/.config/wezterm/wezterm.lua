local w = require("wezterm")
local config = w.config_builder()

config.color_scheme_dirs = { "~/.config/wezterm/colors" }
config.color_scheme = "pax"
config.colors = {
	ansi = {
		"#1a1a1a",
		"#b35959",
		"#59b359",
		"#ccb866",
		"#7aa3cc",
		"#b359b3",
		"#59b3b3",
		"#cccac2",
	},
	background = "#1e1e2e",
	brights = {
		"#4d4d4d",
		"#e66e6e",
		"#6ee66e",
		"#ffdc69",
		"#99ccff",
		"#e673e6",
		"#6ee6e6",
		"#fffdf2",
	},
	cursor_bg = "#ff007b",
	cursor_border = "#ff007b",
	foreground = "#e9e7dd",
}
config.font = w.font("JetBrainsMonoNL Nerd Font Mono") -- has best icon sizes
config.font_size = 15
config.command_palette_font_size = 18
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	top = 0,
	right = 0,
	bottom = 0,
}
config.send_composed_key_when_left_alt_is_pressed = true -- make opt+3 = # on Mac
config.front_end = "WebGpu" -- required for proper nix rendering

return config
