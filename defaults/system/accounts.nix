{ lib, ... }:
let
  registry = import ../../users;
  homeDefaults = lib.filesystem.listFilesRecursive ../home;

  personal = name:
    let p = ../../users + "/${name}.nix";
    in lib.optional (builtins.pathExists p) p;
in
{
  # Declared here so hosts/rog/default.nix can set my.monitors.
  options.my.monitors = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ",preferred,auto,1" ];
    description = "Hyprland monitor lines for this host.";
  };

  config = {
    users.users =
      # root cannot log in directly; use sudo from a wheel account.
      { root.hashedPassword = "!"; }
      //
      lib.mapAttrs (name: u: {
        isNormalUser = true;
        description = u.description or name;
        extraGroups = [ "networkmanager" "video" "audio" "input" "docker" ]
          ++ lib.optional u.admin "wheel"
          ++ (u.extraGroups or [ ]);
      }) registry;

    home-manager.users = lib.mapAttrs (name: u: {
      imports = homeDefaults ++ personal name;
      home.stateVersion = "26.05";
    }) registry;
  };
}
