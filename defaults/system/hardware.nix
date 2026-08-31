{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
  services.blueman.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Backlight is handled by brightnessctl (in defaults/system/packages.nix).
  # programs.light was removed from nixpkgs — unmaintained upstream.

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.udisks2.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend";
}
