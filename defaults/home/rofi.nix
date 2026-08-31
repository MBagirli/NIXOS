{ config, lib, pkgs, ... }:
let
  t = import ../theme.nix;
in
{
  programs.rofi = {
    enable = true;
    # rofi-wayland was merged into rofi upstream; plain rofi now has
    # Wayland support built in.
    package = pkgs.rofi;
    terminal = "${pkgs.kitty}/bin/kitty";

    # Must be set here, NOT inside extraConfig. HM emits this as a
    # proper `@theme "path"` line after the configuration block; putting
    # `theme` inside extraConfig produces the deprecated `theme:` option
    # and rofi refuses to start.
    theme = "${config.xdg.configHome}/rofi/theme.rasi";

    extraConfig = {
      modes = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
      display-drun = "";
      icon-theme = "Papirus-Dark";
    };
  };

  # Written as a raw rasi file rather than through programs.rofi.theme's
  # attrset form: that needs mkLiteral on nearly every value and cannot
  # express the nested selectors below. Kept in the same visual language
  # as keybinds.rasi and power.rasi.
  xdg.configFile."rofi/theme.rasi".text = ''
    * {
      bg:      rgba(${t.rgbBg}, 0.86);
      surface: rgba(${t.rgbSurface}, 0.35);
      fg:      #${t.fg};
      fg-dim:  #${t.fgDim};
      accent:  #${t.accent};

      background-color: transparent;
      text-color:       @fg;
      font:             "${t.font} ${toString t.fontSize}";
    }

    window {
      width:            620px;
      background-color: @bg;
      border:           1px;
      border-color:     rgba(${t.rgbSurface}, 0.8);
      border-radius:    18px;
      padding:          0px;
      children:         [ mainbox ];
    }

    mainbox {
      children: [ inputbar, listview ];
      spacing:  0px;
    }

    /* Search band with a hairline under it */
    inputbar {
      children:         [ entry ];
      background-color: @surface;
      border:           0px 0px 1px 0px;
      border-color:     rgba(${t.rgbSurface}, 0.8);
      border-radius:    18px 18px 0px 0px;
      padding:          16px 24px;
    }

    entry {
      cursor:         text;
      vertical-align: 0.5;
      placeholder:    "";
      text-color:     @fg;
    }

    listview {
      lines:            9;
      columns:          1;
      spacing:          0px;
      padding:          10px 14px 16px 14px;
      background-color: transparent;
      scrollbar:        false;
      dynamic:          true;
    }

    /* Uniform rows — no alternating stripe */
    element {
      padding:          9px 12px;
      border-radius:    10px;
      spacing:          12px;
      background-color: transparent;
      text-color:       @fg;
    }

    element selected {
      background-color: @accent;
      text-color:       #${t.bg};
    }

    element-icon {
      size:             22px;
      background-color: transparent;
      vertical-align:   0.5;
    }

    element-text {
      background-color: transparent;
      text-color:       inherit;
      vertical-align:   0.5;
    }
  '';
}
