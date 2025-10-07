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
local user_params = {
  color_scheme = 'kanagawabones',
  background_image_path = '/Dropbox/Pictures/random-backgrounds/wallhaven-we2l2p.png',
  font = 'FiraCode Nerd Font',
  font_size = 11.0,
  background_tint_opacity = 0.85,
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

-- Set the active color scheme from user_params
config.color_scheme = user_params.color_scheme

-- Set font and font size from user_params
config.font = wezterm.font(user_params.font)
config.font_size = user_params.font_size

-- Background Image Configuration
config.background = {
  -- First layer: the image (drawn first)
  {
    source = {
      File = wezterm.home_dir .. user_params.background_image_path,
    },
    width = "Cover",
    height = "Cover",
  },
  -- Second layer: a color tint (drawn on top of the image)
  {
    source = {
      -- Dynamically get the background color from the active theme
      Color = config.color_schemes[user_params.color_scheme].background,
    },
    -- Apply the desired opacity to this color layer
    opacity = user_params.background_tint_opacity,
    height = "100%",
    width = "100%",
  },
}

-- IMPORTANT: We ensure window_background_opacity is NOT set,
-- so it defaults to 1.0 (fully opaque).

-- Finally, return the configuration
return config
