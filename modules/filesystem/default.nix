{lib, ...}:

with lib;
{
  imports = [
    ./bcachefs.nix
    ./btrfs.nix
    ./encryption.nix
    ./exfat.nix
    ./impermanence.nix
    ./ntfs.nix
    ./swap.nix
    ./tmp.nix
  ];
}
