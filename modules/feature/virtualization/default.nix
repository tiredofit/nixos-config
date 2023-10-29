{config, lib, ...}:
with lib;
{
  imports = [
    ./docker.nix
    ./flatpak.nix
    ./oci-container.nix
    ./virtd.nix
  ];
}