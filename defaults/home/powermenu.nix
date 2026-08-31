{ pkgs, ... }:
let
  t = import ../theme.nix;
in
{
  # Power menu. Split out of waybar.nix so it can carry its own rasi
  # theme, matching the keybind cheatsheet rather than the app launcher.
  home.packages = [
    (pkgs.writeShellScriptBin "power-menu" ''
      # bash printf decodes \u directly; Nix has no unicode escape.
      choice=$(printf '\uf023   Lock\n\uf2f5   Log out\n\uf186   Suspend\n\uf021   Reboot\n\uf011   Shutdown' \
        | ${pkgs.rofi}/bin/rofi -dmenu -i \
            -no-custom \
            -theme "$HOME/.config/rofi/power.rasi")

      case "$choice" in
        *Lock)      hyprlock ;;
        *"Log out") hyprctl dispatch exit ;;
        *Suspend)   systemctl suspend ;;
        *Reboot)    systemctl reboot ;;
        *Shutdown)  systemctl poweroff ;;
      esac
    '')
  ];

  xdg.configFile."rofi/power.rasi".text = ''
    * {
      bg:      rgba(${t.rgbBg}, 0.86);
      fg:      #${t.fg};
      accent:  #${t.accent};
      urgent:  #${t.urgent};

      background-color: transparent;
      text-color:       @fg;
      font:             "${t.font} ${toString t.fontSize}";
    }

    /* No input field at all — five fixed choices, nothing to search. */
    window {
      width:            300px;
      background-color: @bg;
      border:           1px;
      border-color:     rgba(${t.rgbSurface}, 0.8);
      border-radius:    18px;
      padding:          0px;
      children:         [ mainbox ];
    }

    mainbox {
      children: [ listview ];
      spacing:  0px;
    }

    listview {
      lines:            5;
      columns:          1;
      spacing:          0px;
      padding:          12px;
      background-color: transparent;
      scrollbar:        false;
    }

    element {
      padding:          12px 18px;
      border-radius:    12px;
      spacing:          0px;
      background-color: transparent;
      text-color:       @fg;
    }

    element selected {
      background-color: @accent;
      text-color:       #${t.bg};
    }

    /* Shutdown is the destructive one — flag it in red when highlighted */
    element selected.urgent {
      background-color: @urgent;
      text-color:       #${t.bg};
    }

    element-text {
      background-color: transparent;
      text-color:       inherit;
      vertical-align:   0.5;
    }
  '';
}
