{lib, ...}:

with lib;
{
  imports = [
    ./btrfs.nix
    ./encryption.nix
    ./impermanence.nix
    ./swapfile.nix
  ];
}
