{lib, ...}:

with lib;
{
  imports = [
    ./tailscale.nix
    ./wireguard.nix
    ./zerotier.nix
  ];
}
