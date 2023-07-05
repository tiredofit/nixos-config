{ config, pkgs, ... }:
{

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/var/lib/opensnitch"          # Opensnitch
    ];
  };

  services = {
    opensnitch = {
      enable = true;
      rules = {
      };
    };
  };
}
