{lib, ...}:
  with lib;
{
  imports = [
    ./efi.nix
    ./graphical.nix
  ];
}