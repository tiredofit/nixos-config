{ config, pkgs, ... }:
{

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/var/lib/opensnitch"          # Opensnitch
    ];
    files = [
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
