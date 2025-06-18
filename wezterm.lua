-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Your existing config
config.color_scheme = 'Tokyo Night'

-- Set up key bindings
config.keys = {
  -- Set PaneSelect to Ctrl+Shift+J
  {
    key = 'H',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.PaneSelect,
  },
  {
    key = 'L',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal,
  },
  {
    key = 'J',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical,
  },
}

return config
