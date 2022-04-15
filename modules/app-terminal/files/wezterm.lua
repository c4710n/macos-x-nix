local wezterm = require 'wezterm';

function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Solarized Dark Higher Contrast"
  else
    return "Builtin Solarized Light"
  end
end

wezterm.on("window-config-reloaded", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  local scheme = scheme_for_appearance(appearance)
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    window:set_config_overrides(overrides)
  end
end)

return {
   font = wezterm.font("PragmataPro Mono", {weight="Bold"}),
   font_size = 15.0,
   default_prog = {"/run/current-system/sw/bin/tmux", "new-session", "-A", "-s", "main"},

   keys = {
      {key="*", mods="CTRL|ALT", action="ResetFontSize"},
      {key="+", mods="CTRL|ALT", action="IncreaseFontSize"},
      {key="-", mods="CTRL|ALT", action="DecreaseFontSize"},
   },

   hide_tab_bar_if_only_one_tab = true
}
