{ config, lib, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ]; # Facilitate firewall punching
  };

  host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
    "/var/lib/tailscale"
  ];
}