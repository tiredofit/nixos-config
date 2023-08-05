{ config, pkgs, ... }:
{
  services = {
    opensnitch = {
      enable = true;
      rules = {
      };
    };
  };

  hostoptions.impermanence.directories = [
    "/var/lib/opensnitch"          # Opensnitch
  ];
}
