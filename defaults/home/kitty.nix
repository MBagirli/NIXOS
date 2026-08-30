{ lib, ... }:
let t = import ../theme.nix;
in
{
  programs.kitty = {
    enable = true;

    font = {
      name = lib.mkDefault t.font;
      size = lib.mkDefault t.fontSize;
    };

    settings = {
      background = lib.mkDefault "#${t.bg}";
      foreground = lib.mkDefault "#${t.fg}";
      cursor = lib.mkDefault "#${t.accent}";
      selection_background = "#${t.surface}";
      selection_foreground = "#${t.fg}";
      url_color = "#${t.accent}";

      active_tab_background = "#${t.accent}";
      active_tab_foreground = "#${t.bg}";
      inactive_tab_background = "#${t.surface}";
      inactive_tab_foreground = "#${t.fgDim}";

      background_opacity = lib.mkDefault "0.92";
      window_padding_width = lib.mkDefault 8;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      scrollback_lines = 10000;
      tab_bar_style = "powerline";
    };
  };
}
