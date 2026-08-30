{ config, lib, ... }:
let t = import ../theme.nix;
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        grace = 2;
      };

      background = [{
        path = "${config.home.homeDirectory}/.local/share/wallpaper";
        blur_passes = 3;
        blur_size = 8;
        brightness = 0.6;
      }];

      input-field = [{
        size = "280, 48";
        position = "0, -60";
        halign = "center";
        valign = "center";

        outline_thickness = t.border;
        rounding = t.rounding;
        outer_color = "rgb(${t.accent})";
        inner_color = "rgb(${t.surface})";
        font_color = "rgb(${t.fg})";
        check_color = "rgb(${t.warn})";
        fail_color = "rgb(${t.urgent})";

        placeholder_text = "<i>password</i>";
        fade_on_empty = false;
      }];

      label = [
        {
          text = "cmd[update:1000] date +'%H:%M'";
          font_size = 88;
          font_family = t.font;
          color = "rgb(${t.fg})";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          text = "cmd[update:60000] date +'%A, %d %B'";
          font_size = 18;
          font_family = t.font;
          color = "rgb(${t.fgDim})";
          position = "0, 50";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "loginctl lock-session"; }
        {
          timeout = 360;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
