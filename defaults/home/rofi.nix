{ config, lib, pkgs, ... }:
let
  t = import ../theme.nix;
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    # rofi-wayland was merged into rofi upstream; plain rofi now has
    # Wayland support built in.
    package = pkgs.rofi;
    terminal = "${pkgs.kitty}/bin/kitty";
    font = "${t.font} ${toString t.fontSize}";

    extraConfig = {
      modes = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
      display-drun = "  ";
    };

    # rofi's rasi format needs mkLiteral for anything that is not a
    # plain string — colors, sizes, keywords.
    theme = lib.mkDefault {
      "*" = {
        bg = mkLiteral "#${t.bg}";
        bg-alt = mkLiteral "#${t.surface}";
        fg = mkLiteral "#${t.fg}";
        fg-dim = mkLiteral "#${t.fgDim}";
        accent = mkLiteral "#${t.accent}";

        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
      };

      window = {
        width = mkLiteral "600px";
        background-color = mkLiteral "@bg";
        border = mkLiteral "${toString t.border}px";
        border-color = mkLiteral "@accent";
        border-radius = mkLiteral "${toString t.rounding}px";
        padding = mkLiteral "12px";
      };

      inputbar = {
        children = map mkLiteral [ "prompt" "entry" ];
        background-color = mkLiteral "@bg-alt";
        border-radius = mkLiteral "${toString t.rounding}px";
        padding = mkLiteral "8px";
        spacing = mkLiteral "8px";
      };

      prompt.text-color = mkLiteral "@accent";
      entry.placeholder = "search";
      entry.placeholder-color = mkLiteral "@fg-dim";

      listview = {
        lines = 8;
        columns = 1;
        spacing = mkLiteral "4px";
        padding = mkLiteral "12px 0 0 0";
      };

      element = {
        padding = mkLiteral "8px";
        border-radius = mkLiteral "${toString t.rounding}px";
      };

      "element selected" = {
        background-color = mkLiteral "@accent";
        text-color = mkLiteral "#${t.bg}";
      };

      element-icon = {
        size = mkLiteral "22px";
        padding = mkLiteral "0 8px 0 0";
      };
    };
  };
}
