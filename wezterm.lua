-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Your existing config
config.color_scheme = 'Tokyo Night'

-- Set up key bindings
config.keys = {
  {
    key = 'H',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.PaneSelect,
  },
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString("\x1b\r"),
  },
  {
    key = 'L',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'J',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
}

return config
