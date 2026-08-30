{ lib, ... }:
let t = import ../theme.nix;
in
{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = "(250, 420)";
        height = 200;
        origin = "top-right";
        offset = "(12, 46)";      # clears the 34px waybar
        scale = 0;

        frame_width = t.border;
        frame_color = lib.mkForce "#${t.accent}";
        corner_radius = t.rounding;
        separator_color = "frame";
        gap_size = 6;
        padding = 12;
        horizontal_padding = 12;

        font = lib.mkDefault "${t.font} ${toString t.fontSize}";
        markup = "full";
        format = "<b>%s</b>\\n%b";
        word_wrap = true;

        icon_position = "left";
        max_icon_size = 48;

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        background = "#${t.bg}";
        foreground = "#${t.fgDim}";
        timeout = 5;
      };

      urgency_normal = {
        background = "#${t.bg}";
        foreground = "#${t.fg}";
        timeout = 8;
      };

      urgency_critical = {
        background = "#${t.bg}";
        foreground = "#${t.urgent}";
        frame_color = "#${t.urgent}";
        timeout = 0;
      };
    };
  };
}
