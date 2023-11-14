{lib, ...}:

with lib;
{
  imports = [
    ./tailscale.nix
    ./zerotier.nix
  ];
}
