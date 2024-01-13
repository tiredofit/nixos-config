{lib, ...}:

with lib;
{
  imports = [
    ./btrfs.nix
    ./encryption.nix
    ./exfat.nix
    ./impermanence.nix
    ./ntfs.nix
    ./swap.nix
    ./tmp.nix
  ];
}
