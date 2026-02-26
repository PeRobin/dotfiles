local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local wsl_domain = 'WSL:Ubuntu'
local linux_cwd = ''

wezterm.on("gui-startup", function()
  local _, pane, _ = wezterm.mux.spawn_window({
    cwd = linux_cwd,
  })

  local right_pane = pane:split({
    direction = "Right",
    size = 0.5,
    cwd = linux_cwd,
  })

  if right_pane then
    right_pane:split({
      direction = "Bottom",
      size = 0.5,
      cwd = linux_cwd,
    })
  end
end)

config.default_domain = wsl_domain
config.default_cwd = linux_cwd

config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.font_size = 11.0
config.font = wezterm.font("JetBrainsMono NF")
config.color_scheme = "Mariana"
config.window_padding = { left = 15, right = 15, top = 15, bottom = 15 }

return config