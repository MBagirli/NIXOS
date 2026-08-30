{ lib, pkgs, ... }:
let
  t = import ../theme.nix;

  # Nix strings have no \uXXXX escape — it only understands \n \t \r \\ \"
  # and \${. JSON does have one, and fromJSON joins surrogate pairs
  # correctly, so round-tripping gives real glyphs from pure ASCII source.
  # Note the doubled backslash: \\u in Nix yields the literal \u JSON needs.
  u = s: builtins.fromJSON ''"${s}"'';

  # ---- ICON CENTRING ----
  # \uf11c and \uf313 have ink offset from their advance width, so a
  # centred *label* still looks off-centre. Padding cannot fix this: it
  # moves the box, not the ink inside it. The only lever that shifts the
  # ink is the string content itself.
  #
  # A hair space (U+200A) is ~1px at this font size. Add them to the LEFT
  # of a glyph to push it RIGHT, to the RIGHT to push it LEFT.
  # Tune by changing these four numbers only, then rebuild.
  hair = u "\\u200a";
  pad = n: lib.concatStrings (lib.replicate n hair);

  keybindsLeftPad  = 0;   # increase to push the keyboard icon RIGHT
  keybindsRightPad = 6;   # increase to push it LEFT

  powerLeftPad  = 0;      # increase to push the NixOS logo RIGHT
  powerRightPad = 6;      # increase to push it LEFT
in
{
  # NOTE: hypr-keys lives in defaults/home/keybinds.nix, not here.
  home.packages = [
    (pkgs.writeShellScriptBin "power-menu" ''
      choice=$(printf '\uf023  Lock\n\uf2f5  Log out\n\uf186  Suspend\n\uf021  Reboot\n\uf011  Shutdown' \
        | ${pkgs.rofi}/bin/rofi -dmenu -i -p "power" -theme-str 'listview { lines: 5; }')

      case "$choice" in
        *Lock)      hyprlock ;;
        *"Log out") hyprctl dispatch exit ;;
        *Suspend)   systemctl suspend ;;
        *Reboot)    systemctl reboot ;;
        *Shutdown)  systemctl poweroff ;;
      esac
    '')
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = false;   # started via exec-once in hyprland.conf

    settings.main = {
      layer = "top";
      position = "top";
      height = 36;
      # 0 rather than a gap: waybar's spacing is added after each module's
      # content, which would push glyphs left inside their own pill. The
      # pill margins below provide the separation instead.
      spacing = 0;
      margin-left = 6;
      margin-right = 10;

      modules-left = [ "custom/keybinds" "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "cpu" "memory" "disk"
        "pulseaudio" "bluetooth" "network"
        "battery" "custom/power"
      ];

      "custom/keybinds" = {
        format = pad keybindsLeftPad + u "\\uf11c" + pad keybindsRightPad;
        tooltip = true;
        tooltip-format = "Keybinds  (Super+K)";
        on-click = "hypr-keys";
      };

      "custom/power" = {
        format = pad powerLeftPad + u "\\uf313" + pad powerRightPad;
        tooltip = true;
        tooltip-format = "Power menu  (Super+Shift+E)";
        on-click = "power-menu";
      };

      # Hyprland workspaces are virtual desktops. all-outputs makes every
      # bar show every workspace rather than only those on its own monitor.
      "hyprland/workspaces" = {
        format = "{id}";
        all-outputs = true;
        sort-by-number = true;
        persistent-workspaces."*" = 5;
        on-click = "activate";
        on-scroll-up = "hyprctl dispatch workspace e+1";
        on-scroll-down = "hyprctl dispatch workspace e-1";
      };

      clock = {
        format = u "\\uf017" + "  {:%H:%M}";
        format-alt = u "\\uf133" + "  {:%a %d %b %Y}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      cpu = {
        interval = 3;
        format = u "\\uf2db" + "  {usage}%";
        tooltip = true;
        on-click = "kitty btop";
      };

      memory = {
        interval = 5;
        format = u "\\uf538" + "  {percentage}%";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G";
        on-click = "kitty btop";
      };

      disk = {
        interval = 60;
        path = "/";
        format = u "\\uf0a0" + "  {percentage_used}%";
        tooltip-format = "{used} used of {total} on {path}";
      };

      pulseaudio = {
        format = "{icon}  {volume}%";
        format-muted = u "\\uf026" + "  muted";
        format-icons.default = [ (u "\\uf026") (u "\\uf027") (u "\\uf028") ];
        on-click = "pavucontrol";
        on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      };

      bluetooth = {
        format = u "\\uf293";
        format-disabled = u "\\uf294";
        format-connected = u "\\uf293" + "  {num_connections}";
        tooltip-format = "{controller_alias}";
        tooltip-format-connected = "{device_enumerate}";
        on-click = "blueman-manager";
      };

      network = {
        format-wifi = u "\\uf1eb" + "  {signalStrength}%";
        format-ethernet = u "\\uf6ff";
        format-disconnected = u "\\uf05e";
        tooltip-format-wifi = "{essid}  ({signalStrength}%)\n{ipaddr}";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}";
        on-click = "kitty nmtui";
      };

      battery = {
        interval = 30;
        states = { warning = 30; critical = 15; };
        format = "{icon}  {capacity}%";
        format-charging = u "\\uf0e7" + "  {capacity}%";
        format-plugged = u "\\uf1e6" + "  {capacity}%";
        format-icons = [
          (u "\\uf244") (u "\\uf243") (u "\\uf242")
          (u "\\uf241") (u "\\uf240")
        ];
        tooltip-format = "{timeTo}";
      };
    };

    style = lib.mkDefault ''
      * {
        font-family: "${t.font}", "Symbols Nerd Font";
        font-size: ${toString t.fontSize}pt;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      /* fully transparent bar; only the pills are visible */
      window#waybar {
        background: transparent;
        color: #${t.fg};
      }

      /* Text pills: horizontal padding sizes them to their content,
         min-height plus zero vertical padding centres that content. */
      #workspaces,
      #clock,
      #cpu,
      #memory,
      #disk,
      #pulseaudio,
      #bluetooth,
      #network,
      #battery {
        background: rgba(${t.rgbSurface}, 0.55);
        border-radius: ${toString t.rounding}px;
        padding: 0 11px;
        margin: 4px 3px;
        min-height: 24px;
      }

      /* Icon-only pills: no padding, fixed min-width. GTK centres the
         label in its allocation; the hair-space padding in the format
         string above compensates for the glyph's own bearing. */
      #custom-keybinds,
      #custom-power {
        background: rgba(${t.rgbSurface}, 0.55);
        border-radius: ${toString t.rounding}px;
        padding: 0;
        margin: 4px 3px;
        min-height: 24px;
        min-width: 34px;
      }

      #custom-keybinds { color: #${t.accent2}; }
      #custom-power    { color: #${t.accent}; }

      #custom-keybinds:hover,
      #custom-power:hover {
        background: rgba(${t.rgbSurface}, 0.9);
      }

      #workspaces {
        padding: 0 4px;
      }

      #workspaces button {
        padding: 0 8px;
        margin: 3px 1px;
        color: #${t.fgDim};
        background: transparent;
        border-radius: ${toString t.rounding}px;
      }

      #workspaces button.active {
        color: #${t.bg};
        background: #${t.accent};
      }

      #workspaces button.urgent {
        color: #${t.bg};
        background: #${t.urgent};
      }

      #workspaces button:hover {
        background: rgba(${t.rgbBg}, 0.7);
        color: #${t.fg};
      }

      #clock      { color: #${t.accent2}; }
      #cpu        { color: #${t.accent}; }
      #memory     { color: #${t.accent2}; }
      #disk       { color: #${t.warn}; }
      #pulseaudio { color: #${t.accent}; }
      #bluetooth  { color: #${t.accent}; }
      #network    { color: #${t.ok}; }
      #battery    { color: #${t.ok}; }

      #battery.warning  { color: #${t.warn}; }
      #battery.critical { color: #${t.urgent}; }
    '';
  };
}
