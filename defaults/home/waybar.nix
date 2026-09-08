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
  hair = u "\\u200a";
  pad = n: lib.concatStrings (lib.replicate n hair);

  keybindsLeftPad  = 0;
  keybindsRightPad = 6;

  powerLeftPad  = 0;
  powerRightPad = 6;

  # ---- VERTICAL GEOMETRY ----
  # These three must satisfy: pillHeight + 2*vMargin == barHeight
  # Any slack left over is what makes the pills sit off-centre, because
  # GTK has no rule about where to put an odd remainder.
  barHeight  = 36;
  vMargin    = 5;
  pillHeight = barHeight - (2 * vMargin);   # = 26

  # Workspaces shown on EVERY output. An empty list means "not pinned to
  # a particular monitor", which is what makes both bars show the same
  # set instead of Hyprland's per-monitor split.
  persistent = lib.listToAttrs
    (map (n: lib.nameValuePair (toString n) [ ]) (lib.range 1 5));
in
{
  # NOTE: power-menu lives in defaults/home/powermenu.nix and
  # hypr-keys in defaults/home/keybinds.nix.

  programs.waybar = {
    enable = true;
    systemd.enable = false;   # started via exec-once in hyprland.conf

    settings.main = {
      layer = "top";
      position = "top";
      height = barHeight;
      spacing = 0;            # pill margins provide the separation

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

      # Hyprland workspaces are virtual desktops.
      #   all-outputs        -> every bar lists every workspace
      #   persistent-workspaces with empty lists -> 1..5 always present on
      #                         all monitors, so the two bars agree
      #   show-special = false -> hides scratchpad pseudo-workspaces
      "hyprland/workspaces" = {
        format = "{id}";
        all-outputs = true;
        sort-by-number = true;
        show-special = false;
        persistent-workspaces = persistent;
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
      /* min-height: 0 on the universal selector is essential — without it
         GTK's default minimum fights the explicit heights below and the
         pills end up taller than intended, which is what pushes them
         off-centre in the bar. */
      * {
        font-family: "${t.font}", "Symbols Nerd Font";
        font-size: ${toString t.fontSize}pt;
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
      }

      /* fully transparent bar; only the pills are visible */
      window#waybar {
        background: transparent;
        color: #${t.fg};
      }

      /* Every pill. pillHeight + 2*vMargin == barHeight exactly, so there
         is no leftover vertical space for GTK to distribute arbitrarily.
         Zero vertical padding + a fixed min-height is what centres the
         label inside the pill. */
      #custom-keybinds,
      #custom-power,
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
        min-height: ${toString pillHeight}px;
        padding: 0 11px;
        margin: ${toString vMargin}px 3px;
      }

      /* Icon-only pills: no padding, fixed width, glyph centred by GTK */
      #custom-keybinds,
      #custom-power {
        padding: 0;
        min-width: 34px;
      }

      #custom-keybinds { color: #${t.accent2}; }
      #custom-power    { color: #${t.accent}; }

      #custom-keybinds:hover,
      #custom-power:hover {
        background: rgba(${t.rgbSurface}, 0.9);
      }

      /* The workspace container holds buttons rather than a label, so it
         needs its own inner geometry. Button height is pillHeight minus
         its own 2px vertical margin on each side. */
      #workspaces {
        padding: 0 4px;
      }

      #workspaces button {
        min-height: ${toString (pillHeight - 4)}px;
        min-width: ${toString (pillHeight - 4)}px;
        padding: 0 6px;
        margin: 2px 1px;
        color: #${t.fgDim};
        background: transparent;
        border-radius: ${toString t.rounding}px;
      }

      /* An empty workspace that only exists because it is persistent is
         dimmed further, so occupied ones stand out. */
      #workspaces button.empty {
        color: #${t.inactive};
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
