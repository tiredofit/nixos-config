{config, lib, pkgs, ...}:
with lib;
{
  imports = [
    ./niri.nix
    ./cosmic.nix
  ];
}
