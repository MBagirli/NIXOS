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
  networking.firewall.enable = true;

  services.openssh.enable = true;
  services.btrfs.autoScrub.enable = true;

  nixpkgs.config.allowUnfree = true;
}
