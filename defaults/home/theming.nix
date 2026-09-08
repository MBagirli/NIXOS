{ config, lib, pkgs, ... }:
let
  t = import ../theme.nix;
in
{
  # ---- cursor ----
  # home.pointerCursor (rather than just gtk.cursorTheme) also writes the
  # X11 and Hyprland cursor config and exports XCURSOR_THEME /
  # XCURSOR_SIZE, which is what stops the
  # "Unable to load hand2 from the cursor theme" spam.
  home.pointerCursor = {
    enable = true;          # required explicitly since HM 25.11
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
  };

  # ---- GTK (dark) ----
  gtk = {
    enable = true;

    theme = {
      package = pkgs.colloid-gtk-theme.override {
        themeVariants = [ "purple" ];
        colorVariants = [ "dark" ];
        tweaks = [ "rimless" ];
      };
      name = "Colloid-Purple-Dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    # gtk-decoration-layout drops the maximise button from CSD titlebars,
    # which are wasted pixels under a tiling compositor.
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = "appmenu:close";
      gtk-enable-animations = 1;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintslight";
      gtk-xft-rgba = "rgb";
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-decoration-layout = "appmenu:close";
    };
  };

  # ---- Qt (dark, follows GTK) ----
  # platformTheme "gtk3" rather than the deprecated "gtk". This sets
  # QT_QPA_PLATFORMTHEME itself, so do not also set it in
  # home.sessionVariables — two definitions is a build error.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
    style.package = pkgs.adwaita-qt;
  };

  # ---- portal / desktop colour-scheme preference ----
  # color-scheme is what Firefox, Electron apps and anything using the
  # freedesktop appearance portal read. Without it you get dark window
  # frames but light web content.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Colloid-Purple-Dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = 24;
      font-name = "Noto Sans 11";
      monospace-font-name = "${t.font} ${toString t.fontSize}";
    };
  };

  # NOTE: GTK_THEME is deliberately NOT set here. It is a hard override
  # that bypasses the settings daemon, breaks per-app theme choices and
  # makes some GTK4 apps render with no theme at all. gtk.theme.name plus
  # the dconf key above is the supported route and does the same job.
  #
  # QT_QPA_PLATFORMTHEME is likewise omitted — qt.platformTheme.name
  # already sets it.
}
