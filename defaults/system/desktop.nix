{ pkgs, ... }:
{
  # ---- compositor (system-level; HM reuses this package) ----
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # ---- display manager ----
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only     # full glyph set as fallback for missing icons
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "Symbols Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Both lines are required. Setting only defaultUserShell without
  # enabling the module gives you a broken login shell.
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.dconf.enable = true;
  security.polkit.enable = true;
  services.gvfs.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
