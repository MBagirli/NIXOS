{ pkgs, ... }:
{
  # Every default app, CLI and GUI, in one place.
  # Apps whose config is managed in defaults/home/ do NOT belong here —
  # kitty, waybar, rofi, dunst, hyprlock are installed by their
  # programs.*.enable lines.
  environment.systemPackages = with pkgs; [
    # ---- CLI ----
    git
    wget
    curl
    unzip
    p7zip
    tree
    ripgrep
    fd
    file
    lsof
    vim
    fastfetch
    htop
    btop
    brightnessctl
    playerctl
    wl-clipboard
    libnotify
    usbutils
    pciutils
    freerdp

    # ---- screenshots ----
    grim
    slurp
    swappy

    # ---- display management ----
    nwg-displays        # GUI: drag monitors around, writes hypr syntax
    wlr-randr           # CLI equivalent, useful for scripts

    # ---- GUI ----
    firefox
    thunar
    tumbler
    mpv
    imv
    pavucontrol
    networkmanagerapplet

    # ---- icon themes ----
    # papirus is primary; the other two are fallbacks rofi walks when
    # papirus has no match for a .desktop Icon= name
    papirus-icon-theme
    adwaita-icon-theme
    hicolor-icon-theme
  ];
}
