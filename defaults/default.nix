{ lib, ... }:
{
  # Auto-imports every .nix file under defaults/system/.
  # defaults/home/ is NOT imported here — accounts.nix imports it per user.
  imports = lib.filesystem.listFilesRecursive ./system;
}
