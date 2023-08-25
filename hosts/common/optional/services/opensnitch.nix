{ config, lib, pkgs, ... }:
{
  services = {
    opensnitch = {
      enable = true;
      rules = {
      };
    };
  };

  host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
    "/var/lib/opensnitch"          # Opensnitch
  ];
}
