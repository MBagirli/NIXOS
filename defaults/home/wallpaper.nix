{ config, lib, pkgs, ... }:
let
  target = "${config.home.homeDirectory}/.local/share/wallpaper";
in
{
  options.my.wallpaper = lib.mkOption {
    type = lib.types.path;
    default = ../../assets/wallpapers/default.jpg;
    description = ''
      Seed wallpaper. Copied to ~/.local/share/wallpaper on first
      activation only — the user can replace that file at runtime and
      rebuilds will not overwrite it.
    '';
  };

  config = {
    # swaybg rather than hyprpaper. hyprpaper 0.8.4 rejects both the
    # ",path" all-monitors wildcard in its config file ("Monitor eDP-1
    # has no target") and the matching IPC commands ("invalid hyprpaper
    # request"). swaybg paints every output from a single -i argument,
    # with no per-monitor config at all.
    systemd.user.services.swaybg = {
      Unit = {
        Description = "wallpaper";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${target} -m fill";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    home.activation.seedWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "${target}" ]; then
        run mkdir -p "$(dirname "${target}")"
        run cp ${config.my.wallpaper} "${target}"
        run chmod u+w "${target}"
      fi
    '';

    # ~/.config is all read-only store symlinks, so this file is the only
    # thing a user can change without editing the flake.
    home.packages = [
      (pkgs.writeShellScriptBin "set-wallpaper" ''
        if [ -z "$1" ]; then
          echo "usage: set-wallpaper /path/to/image" >&2
          exit 1
        fi
        cp "$1" "${target}"
        chmod u+w "${target}"
        systemctl --user restart swaybg
        echo "wallpaper set"
      '')
    ];
  };
}
