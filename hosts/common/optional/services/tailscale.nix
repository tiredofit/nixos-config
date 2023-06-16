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

  hostoptions.impermanence.directories = lib.mkIf config.hostoptions.impermanence.enable [
    "/var/lib/tailscale"
  ];
}