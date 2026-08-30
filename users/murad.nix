{ pkgs, ... }:
{
  # Extra packages on top of the shared defaults.
  home.packages = with pkgs; [
    # vscode
    # thunderbird
  ];

  # Overrides of the shared look. These work because the matching values
  # in defaults/home/ are wrapped in lib.mkDefault.
  # programs.kitty.font.size = 14;

  programs.git = {
    enable = true;
    settings.user.name = "murad";
    settings.user.email = "murad@example.com";
  };
}
