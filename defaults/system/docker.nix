{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;

    # Reclaims space from stopped containers and dangling images weekly.
    # Matters on a 512G disk that also holds a nix store.
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" "--filter" "until=168h" ];
    };

    # Start the daemon on first socket use rather than at boot.
    # Saves ~200MB idle and a couple of seconds of boot time.
    enableOnBoot = false;
  };

  # The module does not set this itself, so the socket comes up as
  # root:root and only root can reach the daemon — every other user gets
  # "permission denied ... /var/run/docker.sock" no matter what groups
  # they are in.
  systemd.sockets.docker.socketConfig.SocketGroup = "docker";

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker        # TUI, worth having
  ];
}
