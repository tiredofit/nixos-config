{config, lib, ...}:
with lib;
{
  imports = [
    ./container.nix
    ./docker.nix
    ./flatpak.nix
    ./virtd.nix
  ];
}