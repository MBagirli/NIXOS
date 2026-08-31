{ pkgs, ... }:
{
  # Extra packages on top of the shared defaults.
  home.packages = with pkgs; [
    vscode
    keepass
    openconnect
    cmatrix
  ];

  programs.git = {
    enable = true;
    settings.user.name = "mbagirli";
    settings.user.email = "mbagirli2505@gmail.com";
  };
}
