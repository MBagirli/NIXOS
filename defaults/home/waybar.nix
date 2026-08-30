{ lib, ... }:
let t = import ../theme.nix;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = false;

    settings.main = {
      layer = "top";
      position = "top";
      height = 34;
      spacing = 6;

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "bluetooth" "network" "battery" "tray" ];

      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
      };

      "hyprland/window" = {
        max-length = 60;
        separate-outputs = true;
      };

      clock = {
        format = "  {:%H:%M}";
        format-alt = "  {:%a %d %b %Y}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      pulseaudio = {
        format = "{icon}  {volume}%";
        format-muted = "  muted";
        format-icons.default = [ "" "" "" ];
        on-click = "pavucontrol";
      };

      bluetooth = {
        format = "  {status}";
        format-connected = "  {device_alias}";
        on-click = "blueman-manager";
      };

      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "  wired";
        format-disconnected = "  off";
        tooltip-format = "{essid} — {ipaddr}";
        on-click = "nm-connection-editor";
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format = "{icon}  {capacity}%";
        format-charging = "  {capacity}%";
        format-icons = [ "" "" "" "" "" ];
      };

      tray.spacing = 10;
    };

    style = lib.mkDefault ''
      * {
        font-family: "${t.font}";
        font-size: ${toString t.fontSize}pt;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #${t.fg};
      }

      #workspaces button {
        padding: 0 10px;
        color: #${t.fgDim};
        background: transparent;
      }

      #workspaces button.active {
        color: #${t.bg};
        background: #${t.accent};
        border-radius: ${toString t.rounding}px;
      }

      #workspaces button.urgent {
        color: #${t.bg};
        background: #${t.urgent};
        border-radius: ${toString t.rounding}px;
      }

      #window {
        color: #${t.fgDim};
        padding: 0 10px;
      }

      #clock,
      #pulseaudio,
      #bluetooth,
      #network,
      #battery,
      #tray {
        padding: 0 12px;
        margin: 4px 2px;
        background: #${t.surface};
        border-radius: ${toString t.rounding}px;
      }

      #clock       { color: #${t.accent2}; }
      #pulseaudio  { color: #${t.accent}; }
      #bluetooth   { color: #${t.accent}; }
      #network     { color: #${t.ok}; }
      #battery     { color: #${t.ok}; }

      #battery.warning  { color: #${t.warn}; }
      #battery.critical { color: #${t.urgent}; }
    '';
  };
}
