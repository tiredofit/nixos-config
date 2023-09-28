{lib, ...}:

with lib;
{
  imports = [
    ./firewall
    ./hostname.nix
    ./vpn
    ./wired.nix
  ];
}
