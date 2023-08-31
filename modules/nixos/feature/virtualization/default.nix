{config, lib, ...}:
with lib;
{
  imports = [
    ./docker.nix
    ./flatpak.nix
    ./virtd.nix
  ];
}