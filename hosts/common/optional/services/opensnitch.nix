{ config, lib, pkgs, ... }:
{
  services = {
    opensnitch = {
      enable = true;
      rules = {
      };
    };
  };

  hostoptions.impermanence.directories = lib.mkIf config.hostoptions.impermanence.enable [
    "/var/lib/opensnitch"          # Opensnitch
  ];
}
