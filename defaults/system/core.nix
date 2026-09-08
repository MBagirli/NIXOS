{ pkgs, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = 4;          # 16G RAM / 16 threads
    cores = 4;

    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  # 512G disk holding a nix store plus NVIDIA driver generations.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  time.timeZone = "Asia/Baku";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  networking.networkmanager.enable = true;

  # ---- firewall ----
  # Every port the machine accepts is listed here, in one place.
  # 22 is also opened by services.openssh below; naming it explicitly
  # keeps the whole inbound surface visible in a single line.
  #
  # 5900 (wayvnc) is deliberately NOT opened. `virtual-monitor listen`
  # binds wayvnc to 0.0.0.0, but wayvnc has no encryption or auth of its
  # own, so opening it would hand the desktop to anyone on the same wifi.
  # Reach it over the ssh you already run:
  #   ssh -L 5900:localhost:5900 rog
  # then point the viewer at localhost:5900.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.openssh.enable = true;
  services.btrfs.autoScrub.enable = true;

  nixpkgs.config.allowUnfree = true;
}
