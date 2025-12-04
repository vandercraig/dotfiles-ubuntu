-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Load the wez-tmux plugin for tmux-like keybindings
local wez_tmux = wezterm.plugin.require("https://github.com/sei40kr/wez-tmux.git")

-- bar
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")

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

-- Settings for local (non-SSH) sessions
local hostname_params = {
	["lupa"] = {
		color_scheme = "kurokula",
		background_image_path = "/Dropbox/Pictures/random-backgrounds/lupa/lupa2.jpg",
		initial_background_image = "/Dropbox/Pictures/random-backgrounds/lupa/lupa2.png",
		font = "FiraCode Nerd Font",
		font_size = 12.0,
		background_tint_opacity = 0.83,
	},
	["iuno"] = {
		color_scheme = "tokyonight",
		background_image_path = "/Dropbox/Pictures/random-backgrounds/iuno/iuno5.jpg",
		initial_background_image = "/Dropbox/Pictures/random-backgrounds/iuno/iuno3.jpg",
		font = "FiraCode Nerd Font",
		font_size = 12.0,
		background_tint_opacity = 0.85,
	},
  ["cartethyia"] = {

  }
}

-- Settings for SSH sessions
local ssh_params = {
  color_scheme = hostname_params["lupa"].color_scheme,
  background_image_path = hostname_params["lupa"].background_image_path,
  font = hostname_params["lupa"].font,
  font_size = hostname_params["lupa"].font_size,
  background_tint_opacity = 0.85, -- Override this one
}

-- Get the current hostname to select appropriate parameters
local hostname = wezterm.hostname()
if not hostname_params[hostname] then
    hostname = "lupa"
end

local local_params = hostname_params[hostname]

-- -----------------------------------------------------------------------------
-- Apply User Parameters to Configuration
-- -----------------------------------------------------------------------------

-- Set default (local) color scheme, font, and font size
config.color_scheme = local_params.color_scheme
config.font = wezterm.font(local_params.font)
config.font_size = local_params.font_size

-- -----------------------------------------------------------------------------
-- Dynamic Configuration Based on SSH Status
-- -----------------------------------------------------------------------------
-- This function detects if we're in an SSH session
local function is_ssh_session(pane)
	if not pane then
		return false
	end

	-- Check if we're in an SSH session by looking at the pane's user variables
	local user_vars = pane:get_user_vars()
	if user_vars.SSH_CONNECTION or user_vars.SSH_CLIENT or user_vars.SSH_TTY then
		return true
	end

	-- Also check the foreground process name
	local foreground_process = pane:get_foreground_process_name()
	if foreground_process and foreground_process:find("ssh") then
		return true
	end

	return false
end

-- This function returns the appropriate background configuration
local function get_background_for_params(params)
	return {
		-- First layer: the image (drawn first)
		{
			source = {
				File = wezterm.home_dir .. params.background_image_path,
			},
			width = "Cover",
			height = "Cover",
		},
		-- Second layer: a color tint (drawn on top of the image)
		{
			source = {
				-- Dynamically get the background color from the active theme
				Color = wezterm.color.get_builtin_schemes()[params.color_scheme].background,
			},
			-- Apply the desired opacity to this color layer
			opacity = params.background_tint_opacity,
			height = "100%",
			width = "100%",
		},
	}
end

local function extend_color_scheme(hostname, config)
  local tab_bar = config.colors.tab_bar or {}
  -- Customize tab bar colors based on hostname
  if hostname == "lupa" then
    tab_bar.background = "#141515"
    tab_bar.active_tab.bg_color = "#b66056"
    tab_bar.active_tab.fg_color = "#333333"
    tab_bar.inactive_tab.bg_color = "#333333"
    tab_bar.inactive_tab.fg_color = "#b66056"
    tab_bar.new_tab.bg_color = "#141515"
    tab_bar.new_tab.fg_color = "#dbbb43"

  end

  return tab_bar
end

-- Set initial background (will be updated dynamically)
config.background = get_background_for_params(local_params)
-- -----------------------------------------------------------------------------
-- Event Handler: Update Configuration on Window Focus
-- -----------------------------------------------------------------------------
-- This event fires when a window or pane gains focus, allowing us to
-- dynamically update the background, color scheme, font, and font size based on SSH status.
wezterm.on('update-status', function(window, pane)
  local params = is_ssh_session(pane) and ssh_params or local_params
  local bg = get_background_for_params(params)

  window:set_config_overrides({
    background = bg,
    color_scheme = params.color_scheme,
    font = wezterm.font(params.font),
    font_size = params.font_size,
  })
end)

-- IMPORTANT: We ensure window_background_opacity is NOT set,
-- so it defaults to 1.0 (fully opaque).

-- Apply wez-tmux plugin keybindings
wez_tmux.apply_to_config(config)

-- Apply bar plugin configuration

bar.apply_to_config(config, {
	position = "bottom",
	modules = {
		workspace = { enabled = false },
		clock = { format = "%I:%M %p" },
	},
})

-- Some color schemes don't have a fully fleshed out scheme,
-- so they need to be manually extended.
config.colors.tab_bar = extend_color_scheme(hostname, config)

-- Finally, return the configuration
return config
