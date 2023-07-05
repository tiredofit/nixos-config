{ config, pkgs, ... }:
{
  services = {
    sssd = {
      enable = true;
      sshAuthorizedKeysintegration = true;
        PermitRootLogin = "no" ;
      };
      config = ''
      '';
    };
  };
}
