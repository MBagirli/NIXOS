{ pkgs, ... }:
{
  # ---- compositor (system-level; HM reuses this package) ----
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # ---- display manager ----
  # PASS 2: leave this commented until `nvidia-smi` and `nvidia-offload`
  # are confirmed working from the TTY. Enabling SDDM before the driver
  # is verified is how you end up at a black screen with no console.
  #
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
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
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
