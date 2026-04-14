local w = require("wezterm")
local config = w.config_builder()

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

local function get_system_appearance()
	return w.gui and w.gui.get_appearance() or "Dark"
end

local function get_scheme_by_appearance(system_appearance)
	return system_appearance:find("Dark") and "pax-dark" or "pax-light"
end
config.color_scheme = get_scheme_by_appearance(get_system_appearance())

local function broadcast_scheme_to_nvim(system_appearance)
	-- The child process runs in a shell that doesn't have much in it, so specify nvim location.
	local nvim = os.getenv("HOME") .. "/.nix-profile/bin/nvim"
	local nvim_bg = system_appearance:find("Dark") and "dark" or "light"
	-- This script will:
	-- lsof ...           <-- find all -UNIX domain socket files AND called nvim
	-- awk ... | sort ... <-- skip the header row and find rows where last column ends /nvim.<pid>.0, deduplicate
	-- xargs ...          <-- for each socket path, run a command in the nvim server to set background
	w.run_child_process({
		"bash",
		"-c",
		[[lsof -U -a -c nvim 2>/dev/null | awk 'NR>1 && $NF ~ /\/nvim\.[0-9]+\.0$/ {print $NF}' | sort -u | xargs -I {} ]]
			.. nvim
			.. [[ --headless --server {} --remote-expr "nvim_command('set background=]]
			.. nvim_bg
			.. [[')"]],
	})
end

w.on("window-config-reloaded", function(window)
	local overrides = window:get_config_overrides() or {}
	local appearance = get_system_appearance()
	local scheme = get_scheme_by_appearance(appearance)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
		broadcast_scheme_to_nvim(appearance)
	end
end)

return config
