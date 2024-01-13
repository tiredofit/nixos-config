{lib, ...}:

with lib;
{
  imports = [
    ./btrfs.nix
    ./encryption.nix
    ./impermanence.nix
    ./ntfs.nix
    ./swap.nix
    ./tmp.nix
  ];
}
