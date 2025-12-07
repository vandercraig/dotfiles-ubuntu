-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Load the wez-tmux plugin for tmux-like keybindings
local wez_tmux = wezterm.plugin.require("https://github.com/sei40kr/wez-tmux.git")

-- bar
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")

-- appearance-manager
local appearance_manager = require("appearance-manager")

-- This will hold our configuration
local config = {}

-- In newer versions of WezTerm, we need to check for and use config.color_schemes
-- This is the recommended way to add custom themes
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Configure your leader key (recommended to avoid conflicts)
config.leader = { key = "a", mods = "CTRL" } -- Use Ctrl+a instead of default Ctrl+b

-- -----------------------------------------------------------------------------
-- User Parameters:
-- Easy-to-edit settings for personalization.
-- -----------------------------------------------------------------------------

-- Register a custom color scheme "lupa-custom" based on "kurokula"
-- that has tab bar colors added.
local lupa_color_scheme = wezterm.color.get_builtin_schemes()["kurokula"]
lupa_color_scheme.tab_bar = {
	background = "#141515",
	active_tab = {
		bg_color = "#b66056",
		fg_color = "#333333",
	},
	inactive_tab = {
		bg_color = "#333333",
		fg_color = "#b66056",
	},
	new_tab = {
		bg_color = "#141515",
		fg_color = "#dbbb43",
	},
}

config.color_schemes = {
	["lupa-custom"] = lupa_color_scheme,
}

local appearance_profiles = {
	["lupa"] = {
		display_name = "Lupa",
		color_scheme = "lupa-custom",
		background_image_path = "/Dropbox/Pictures/random-backgrounds/lupa/",
		background_image = "lupa5.jpg",
		font = "FiraCode Nerd Font",
		font_size = 12.0,
		background_tint_opacity = 0.80,
	},
	["iuno"] = {
		display_name = "Iuno",
		color_scheme = "tokyonight",
		background_image_path = "/Dropbox/Pictures/random-backgrounds/iuno/",
		background_image = "iuno6.png",
		font = "FiraCode Nerd Font",
		font_size = 12.0,
		background_tint_opacity = 0.7,
	},
	["cartethyia"] = {
		display_name = "Cartethyia",
		color_scheme = "tokyonight",
		background_image_path = "/Dropbox/Pictures/random-backgrounds/cartethyia/",
		background_image = "cartethyia.png",
		font = "FiraCode Nerd Font",
		font_size = 12.0,
		background_tint_opacity = 0.85,
	},
}

-- Settings for SSH sessions
-- local ssh_params = {
--   color_scheme = hostname_params["lupa"].color_scheme,
--   background_image = hostname_params["lupa"].background_image,
--   font = hostname_params["lupa"].font,
--   font_size = hostname_params["lupa"].font_size,
--   background_tint_opacity = 0.85, -- Override this one
-- }

-- -----------------------------------------------------------------------------
-- Dynamic Configuration Based on SSH Status
-- -----------------------------------------------------------------------------
-- This function detects if we're in an SSH session
-- local function is_ssh_session(pane)
-- 	if not pane then
-- 		return false
-- 	end

-- 	-- Check if we're in an SSH session by looking at the pane's user variables
-- 	local user_vars = pane:get_user_vars()
-- 	if user_vars.SSH_CONNECTION or user_vars.SSH_CLIENT or user_vars.SSH_TTY then
-- 		return true
-- 	end

-- 	-- Also check the foreground process name
-- 	local foreground_process = pane:get_foreground_process_name()
-- 	if foreground_process and foreground_process:find("ssh") then
-- 		return true
-- 	end

-- 	return false
-- end

-- -----------------------------------------------------------------------------
-- Event Handler: Update Configuration on Window Focus
-- -----------------------------------------------------------------------------
-- This event fires when a window or pane gains focus, allowing us to
-- dynamically update the background, color scheme, font, and font size based on SSH status.
-- wezterm.on('update-status', function(window, pane)
--   local params = is_ssh_session(pane) and ssh_params or local_params
--   local bg = get_background_for_params(params)

--   window:set_config_overrides({
--     background = bg,
--     color_scheme = params.color_scheme,
--     font = wezterm.font(params.font),
--     font_size = params.font_size,
--   })
-- end)

-- Apply wez-tmux plugin keybindings
wez_tmux.apply_to_config(config)

-- Apply bar plugin configuration

bar.apply_to_config(config, {
	position = "bottom",
	modules = {
		workspace = { enabled = false },
		clock = { format = "%I:%M %p" },
		username = { enabled = false },
	},
})

-- Get the current hostname to select appropriate parameters
local hostname = wezterm.hostname()
if not appearance_profiles[hostname] then
	hostname = "lupa"
end

local appearance_options = {
	initial_profile = hostname,
	profiles = appearance_profiles,
}

appearance_manager.apply_to_config(config, appearance_options)

return config
