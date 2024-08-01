{lib, ...}:

with lib;
{
  imports = [
    ./bridge.nix
    ./firewall
    ./domainname.nix
    ./hostname.nix
    ./vpn
    ./wired.nix
  ];
}
