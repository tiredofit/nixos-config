{lib, ...}:

with lib;
{
  imports = [
    ./btrfs.nix
    ./encryption.nix
    ./impermanence.nix
    ./swap.nix
  ];
}
