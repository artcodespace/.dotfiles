local w = require("wezterm")
local config = w.config_builder()

local dark_scheme = w.get_builtin_color_schemes()["Catppuccin Mocha (Gogh)"]
local light_scheme = w.get_builtin_color_schemes()["Catppuccin Latte (Gogh)"]
dark_scheme.foreground = "#e9e7dd" -- these are for consistency with nvim
light_scheme.foreground = "#19191f"

config.color_schemes = {
	["light"] = light_scheme,
	["dark"] = dark_scheme,
}
config.color_scheme = "dark"
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
