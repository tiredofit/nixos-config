{lib, ...}:

with lib;
{
  imports = [
    ./firewall
    ./domainname.nix
    ./hostname.nix
    ./vpn
    ./wired.nix
  ];
}
