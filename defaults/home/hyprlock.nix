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
        ignore_empty_input = true;
      };

      # Same wallpaper the desktop uses, blurred and dimmed so the
      # foreground stays readable.
      background = [{
        path = "${config.home.homeDirectory}/.local/share/wallpaper";
        blur_passes = 3;
        blur_size = 7;
        noise = "0.012";
        contrast = "0.9";
        brightness = "0.45";
        vibrancy = "0.17";
        vibrancy_darkness = "0.0";
      }];

      input-field = [{
        size = "320, 52";
        position = "0, -80";
        halign = "center";
        valign = "center";

        outline_thickness = 2;
        rounding = 26;

        # rgba() here is AARRGGBB-ish in hypr syntax: the last two hex
        # digits are alpha. 33 ~ 20% opaque, 66 ~ 40%.
        inner_color = "rgba(${t.surface}33)";
        outer_color = "rgba(${t.accent}66)";
        font_color  = "rgb(${t.fg})";
        check_color = "rgba(${t.warn}aa)";
        fail_color  = "rgba(${t.urgent}aa)";

        placeholder_text = ''<span foreground="##${t.fgDim}"><i>password</i></span>'';
        fail_text = ''<span foreground="##${t.urgent}">$FAIL</span>'';

        dots_size = "0.28";
        dots_spacing = "0.32";
        dots_center = true;
        dots_rounding = -1;

        fade_on_empty = false;
        hide_input = false;
        shadow_passes = 2;
        shadow_size = 4;
        shadow_color = "rgba(00000055)";
      }];

      label = [
        # clock
        {
          text = "cmd[update:1000] date +'%H:%M'";
          font_size = 96;
          font_family = "${t.font} Bold";
          color = "rgba(${t.fg}f2)";
          position = "0, 140";
          halign = "center";
          valign = "center";
          shadow_passes = 3;
          shadow_size = 6;
          shadow_color = "rgba(00000066)";
        }
        # date
        {
          text = "cmd[update:60000] date +'%A, %d %B'";
          font_size = 18;
          font_family = t.font;
          color = "rgba(${t.fgDim}cc)";
          position = "0, 62";
          halign = "center";
          valign = "center";
        }
        # user, under the field
        {
          text = "$USER";
          font_size = 14;
          font_family = t.font;
          color = "rgba(${t.fgDim}aa)";
          position = "0, -150";
          halign = "center";
          valign = "center";
        }
        # battery, bottom right
        {
          text = "cmd[update:30000] cat /sys/class/power_supply/BAT0/capacity 2>/dev/null | sed 's/$/%/'";
          font_size = 13;
          font_family = t.font;
          color = "rgba(${t.fgDim}99)";
          position = "-30, 24";
          halign = "right";
          valign = "bottom";
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
