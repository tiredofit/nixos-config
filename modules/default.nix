{lib, ...}:

with lib;
{
  imports = [
    ./zerotier-systemd-manager.nix
    ./zt-dns-companion.nix
  ];
}