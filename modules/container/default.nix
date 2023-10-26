{lib, ...}:

with lib;
{
  imports = [
    ./socket-proxy.nix
    ./unbound.nix
  ];
}
