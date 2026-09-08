{ config, lib, ... }:
let
  registry = import ../../users;
  homeDefaults = lib.filesystem.listFilesRecursive ../home;

  personal = name:
    let p = ../../users + "/${name}.nix";
    in lib.optional (builtins.pathExists p) p;

  # Catalog declared in defaults/system/packages.nix. Turning a name from
  # users/default.nix into a real package happens here, so a name that is
  # not in the catalog fails the build with a message that says which user
  # asked for it — rather than being silently ignored.
  catalog = config.my.optionalPackages;

  chosen = name: u: map (p:
    catalog.${p} or (throw ''
      users/default.nix: user "${name}" asks for package "${p}", which is
      not in my.optionalPackages. Add it to defaults/system/packages.nix
      or fix the spelling. Available: ${lib.concatStringsSep ", " (lib.attrNames catalog)}
    '')
  ) (u.packages or [ ]);
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

      # Per-package opt-in. Everything a user can have is declared once in
      # packages.nix; this line is what actually puts the chosen ones into
      # that user's profile and nobody else's.
      home.packages = chosen name u;
    }) registry;
  };
}
