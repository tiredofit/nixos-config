{lib, ...}:

with lib;
{
  imports = [
    ./firewall
    ./domain.nix
    ./hostname.nix
    ./vpn
    ./wired.nix
  ];
}
