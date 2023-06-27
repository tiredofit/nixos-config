{ config, pkgs, ... }:
{
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no" ;
      };
    };
  };
}
