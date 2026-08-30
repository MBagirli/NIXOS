{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ---- btrfs options that generate-config omitted ----
  # lists merge by appending, so these join the subvol= from hardware-configuration
  fileSystems."/".options        = [ "compress=zstd:1" "noatime" "ssd" "discard=async" ];
  fileSystems."/home".options    = [ "compress=zstd:1" "noatime" "ssd" "discard=async" ];
  fileSystems."/nix".options     = [ "compress=zstd:1" "noatime" "ssd" "discard=async" ];
  fileSystems."/var/log".options = [ "compress=zstd:1" "noatime" "ssd" "discard=async" ];

  # ---- boot ----
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # ---- network ----
  networking.hostName = "rog";
  networking.networkmanager.enable = true;

  # ---- locale ----
  time.timeZone = "Asia/Baku";
  i18n.defaultLocale = "en_US.UTF-8";

  # ---- nix ----
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.max-jobs = 4;
  nixpkgs.config.allowUnfree = true;

  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  services.openssh.enable = true;
  services.btrfs.autoScrub.enable = true;

  users.users.murad = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    initialPassword = "changeme";
  };

  environment.systemPackages = with pkgs; [ git vim wget curl ];

  system.stateVersion = "26.05";
}
