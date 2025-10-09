-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold our configuration
local config = {}

-- In newer versions of WezTerm, we need to check for and use config.color_schemes
-- This is the recommended way to add custom themes
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- -----------------------------------------------------------------------------
-- User Parameters:
-- Easy-to-edit settings for personalization.
-- -----------------------------------------------------------------------------

-- Settings for local (non-SSH) sessions
local local_params = {
  color_scheme = 'kanagawabones',
  background_image_path = '/Dropbox/Pictures/random-backgrounds/wallhaven-we2l2p.png',
  font = 'FiraCode Nerd Font',
  font_size = 12.0,
  background_tint_opacity = 0.85,
}

-- Settings for SSH sessions
local ssh_params = {
  color_scheme = 'tokyonight',  -- Can be different from local
  background_image_path = '/Dropbox/Pictures/random-backgrounds/lupa.png',
  font = 'FiraCode Nerd Font',  -- Can be different from local
  font_size = 12.0,  -- Can be different from local
  background_tint_opacity = 0.85,  -- Can be different from local
}

-- -----------------------------------------------------------------------------
-- Theme Definitions:
-- Add or modify color schemes here.
-- -----------------------------------------------------------------------------
config.color_schemes = {
  tokyonight = {
    foreground         = '#D5DAF3',
    background         = '#0F1016',
    cursor_bg          = '#C0CAF5',
    cursor_border      = '#C0CAF5',
    cursor_fg          = '#0F1016',
    selection_bg       = '#33467C',
    selection_fg       = '#D5DAF3',
    ansi               = { '#15161E', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#C0C4D6' },
    brights            = { '#B9BFD9', '#F7768E', '#9ECE6A', '#E0AF68', '#7AA2F7', '#BB9AF7', '#7DCFFF', '#D2D8F2' },
  },

  kanagawabones = {
    foreground         = '#ddd8bb',
    background         = '#1f1f28',
    cursor_bg          = '#e6e0c2',
    cursor_border      = '#e6e0c2',
    cursor_fg          = '#1f1f28',
    selection_bg       = '#49473e',
    selection_fg       = '#ddd8bb',
    ansi               = { '#1f1f28', '#e46a78', '#98bc6d', '#e5c283', '#7eb3c9', '#957fb8', '#7eb3c9', '#ddd8bb' },
    brights            = { '#3c3c51', '#ec818c', '#9ec967', '#f1c982', '#7bc2df', '#a98fd2', '#7bc2df', '#a8a48d' },
  },
}

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
  if foreground_process and foreground_process:find('ssh') then
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
        Color = config.color_schemes[params.color_scheme].background,
      },
      -- Apply the desired opacity to this color layer
      opacity = params.background_tint_opacity,
      height = "100%",
      width = "100%",
    },
  }
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

-- Finally, return the configuration
return config
