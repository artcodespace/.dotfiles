local w = require("wezterm")
local config = w.config_builder()

config.color_scheme = "pax-dark"
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

w.on("augment-command-palette", function()
	return { { brief = "Toggle colour theme", icon = "fa_sun_o", action = w.action.EmitEvent("toggle-colorscheme") } }
end)
w.on("toggle-colorscheme", function(window)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == "pax-dark" then
		overrides.color_scheme = "pax-light"
	else
		overrides.color_scheme = "pax-dark"
	end
	window:set_config_overrides(overrides)
end)

return config
