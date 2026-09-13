-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Your existing config
config.color_scheme = 'Tokyo Night'

-- Hyperlinks: start from the built-in URL matchers, then add bare
-- localhost/127.0.0.1 addresses (dev servers print these without a scheme).
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[\b(?:localhost|127\.0\.0\.1)(?::\d+)(?:/\S*)?]],
  format = 'http://$0',
})

-- Plain left-click already opens links, but only when the foreground program
-- isn't grabbing the mouse. TUIs (Claude Code, vim, lazygit) turn on mouse
-- reporting and swallow the click. SHIFT-click bypasses that by default;
-- these bindings make CMD-click work in both modes, like iTerm2/Terminal.app.
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.OpenLinkAtMouseCursor,
    mouse_reporting = true,
  },
  -- Don't forward the CMD-down to the application, or the TUI reacts to the
  -- click before we get to open the link.
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = wezterm.action.Nop,
    mouse_reporting = true,
  },
}

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
