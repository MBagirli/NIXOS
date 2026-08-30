{ config, lib, pkgs, ... }:
{
  # AMD Renoir iGPU + NVIDIA RTX 3050 Ti (GA107M).
  # Bus IDs come from lspci: 01:00.0 nvidia, 05:00.0 amd.
  # lspci prints hex, NixOS wants decimal — they coincide here.

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # Mesa's radeonsi already provides VAAPI and Vulkan (RADV) on Renoir.
    # These are the legacy VDPAU translation layer — safe to empty out
    # entirely if any of them errors on a future nixpkgs bump.
    extraPackages = with pkgs; [
      libva
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;      # required for Wayland
    nvidiaSettings = true;

    # Ampere supports the open kernel modules, but the proprietary ones
    # are still the safer default. Flip to true once things are stable.
    open = false;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement = {
      enable = true;
      finegrained = true;           # dGPU powers down when idle; needs offload
    };

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;    # provides the `nvidia-offload` wrapper
      };
      amdgpuBusId  = "PCI:5:0:0";
      nvidiaBusId  = "PCI:1:0:0";
    };
  };

  # AMD iGPU drives the display; NVIDIA only wakes for offloaded apps.
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
  };
}
