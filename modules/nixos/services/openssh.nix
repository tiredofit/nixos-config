{ config, pkgs, ... }:
{
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no" ;
      };
    };

    fail2ban.jails = {
      sshd = ''
        enabled = true
        mode = extra
      '';
      sshd-aggresive = ''
        enabled = true
        filter = sshd[mode=aggressive]
      '';
    };
  };
}
