{ pkgs, ... }:
{
  # Every default app, CLI and GUI, in one place.
  # Apps whose config is managed in defaults/home/ do NOT belong here —
  # kitty, waybar, rofi, dunst, hyprlock are installed by their
  # programs.*.enable lines.
  environment.systemPackages = with pkgs; [
    # --- CLI ---
    git
    wget
    curl
    unzip
    p7zip
    tree
    ripgrep
    fd
    fastfetch
    htop
    btop
    brightnessctl
    playerctl
    wl-clipboard
    grim
    slurp
    libnotify
    usbutils
    pciutils

    # --- GUI ---
    firefox
    thunar
    tumbler
    mpv
    imv
    pavucontrol
    networkmanagerapplet
  ];
}
