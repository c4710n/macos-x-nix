local wezterm = require 'wezterm';

function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "Modus Vivendi"
  else
    return "Modus Operandi"
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

function color_schemes()
   return {
      ["Modus Operandi"] = {
         background = "#ffffff",
         foreground = "#000000",
         cursor_bg = "#000000",
         cursor_fg = "#ffffff",
         cursor_border = "#000000",
         selection_fg = "#ffffff",
         selection_bg = "#813e00",
         ansi = {"#ffffff", "#a60000", "#005e00", "#813e00", "#0031a9", "#721045", "#00538b", "#000000"},
         brights = {"#5C6370", "#a60000", "#005e00", "#813e00", "#0031a9", "#721045", "#00538b", "#000000"},
      },

      ["Modus Vivendi"] = {
         background = "#000000",
         foreground = "#ffffff",
         cursor_bg = "#ffffff",
         cursor_fg = "#000000",
         cursor_border = "#ffffff",
         selection_fg = "#000000",
         selection_bg = "#d0bc00",
         ansi = {"#000000", "#ff8059", "#44bc44", "#d0bc00", "#2fafff", "#feacd0", "#00d3d0", "#ffffff"},
         brights = { "#5c6370", "#ff8059", "#44bc44", "#d0bc00", "#2fafff", "#feacd0", "#00d3d0", "#ffffff"},
      }
   }
end

return {
   font = wezterm.font("PragmataPro Mono"),
   font_size = 15.0,
   freetype_load_flags = "NO_HINTING",

   color_schemes = color_schemes(),

   default_prog = {"/run/current-system/sw/bin/tmux", "new-session", "-A", "-s", "main"},

   keys = {
      {key="*", mods="CTRL|ALT", action="ResetFontSize"},
      {key="+", mods="CTRL|ALT", action="IncreaseFontSize"},
      {key="-", mods="CTRL|ALT", action="DecreaseFontSize"},
   },

   audible_bell = "Disabled",
   visual_bell = {
      fade_in_duration_ms = 75,
      fade_out_duration_ms = 75,
      target = "CursorColor",
   },

   hide_tab_bar_if_only_one_tab = true
}
