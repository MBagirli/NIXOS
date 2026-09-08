{ ... }:
{
  # Personal settings only. Packages are NOT listed here any more — they
  # are declared in defaults/system/packages.nix and switched on by name
  # in users/default.nix, so every package in the system has one home.
  programs.git = {
    enable = true;
    settings.user.name = "mbagirli";
    settings.user.email = "mbagirli2505@gmail.com";
  };
}
