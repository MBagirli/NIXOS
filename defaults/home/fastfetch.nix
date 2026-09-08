{ lib, pkgs, ... }:
let
  t = import ../theme.nix;
  # Nix has no \uXXXX escape; JSON does, and fromJSON joins surrogate
  # pairs. Every icon and ANSI escape below goes through this.
  u = s: builtins.fromJSON ''"${s}"'';

  esc = u "\\u001b";
  rule = "${esc}[38;5;60m────────────────────────────────${esc}[0m";

  # The logo ships with the flake, so it exists on a fresh install and for
  # every user. It used to point at ~/.config/fastfetch/logo.txt, which
  # nothing created — the file only existed because it had been dropped
  # there by hand, and a reinstall would have lost it.
  #
  # assets/ascii/ holds two: logo-comet.txt (in use) and logo.txt.
  # Swap the line below to switch.
  logoFile = ../../assets/ascii/logo-comet.txt;
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        # type = "file"      -> printed in colour "1" below
        # type = "file-raw"  -> keeps any ANSI colour codes in the file
        type = "file";
        source = logoFile;

        # Colour "1" tints the whole logo. Colour "2" only applies to text
        # marked with a literal $2 in the art — there is none in these
        # files, so it is not set here. Add $1/$2 markers to the .txt if
        # you want two-tone.
        color = { "1" = "blue"; };

        padding = { top = 2; right = 4; left = 2; };
      };

      display = {
        separator = "  ";
        key = { width = 12; };
      };

      modules = [
        "break"
        {
          type = "title";
          format = "{user-name}${esc}[38;5;60m@${esc}[0m{host-name}";
        }
        { type = "custom"; format = rule; }

        { type = "os";       key = u "\\uf313" + " os";     keyColor = "blue"; }
        { type = "kernel";   key = u "\\uf17c" + " kernel"; keyColor = "blue"; }
        { type = "wm";       key = u "\\uf2d2" + " wm";     keyColor = "blue"; }
        { type = "shell";    key = u "\\uf120" + " shell";  keyColor = "blue"; }
        { type = "terminal"; key = u "\\uf489" + " term";   keyColor = "blue"; }
        { type = "packages"; key = u "\\uf487" + " pkgs";   keyColor = "blue"; }

        { type = "custom"; format = rule; }

        { type = "cpu";     key = u "\\uf2db" + " cpu";  keyColor = "magenta"; }
        { type = "gpu";     key = u "\\uf108" + " gpu";  keyColor = "magenta"; format = "{name}"; }
        { type = "memory";  key = u "\\uf538" + " ram";  keyColor = "magenta"; }
        { type = "disk";    key = u "\\uf0a0" + " disk"; keyColor = "magenta"; folders = "/"; }
        { type = "battery"; key = u "\\uf240" + " batt"; keyColor = "magenta"; }

        { type = "custom"; format = rule; }

        { type = "uptime"; key = u "\\uf017" + " up"; keyColor = "green"; }

        "break"
        { type = "colors"; symbol = "circle"; paddingLeft = 2; }
        "break"
      ];
    };
  };
}
