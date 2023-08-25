{ config, lib, pkgs, ... }:
{
  services = {
    opensnitch = {
      enable = true;
      rules = {
      };
    };
  };

  host.feature.impermanence.directories = lib.mkIf config.host.feature.impermanence.enable [
    "/var/lib/opensnitch"          # Opensnitch
  ];
}
