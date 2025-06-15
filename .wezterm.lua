-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Your existing config
config.color_scheme = 'Tokyo Night'

-- Set up key bindings
config.keys = {
  -- Set PaneSelect to Ctrl+Shift+T
  {
    key = 'T',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.PaneSelect,
  },
}

return config
