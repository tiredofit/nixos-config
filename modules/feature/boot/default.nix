{lib, ...}:
  with lib;
{
  imports = [
    ./efi.nix
    ./graphical.nix
    ./initrd.nix
    ./kernel.nix
  ];
}