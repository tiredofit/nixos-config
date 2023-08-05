{ config, pkgs, ... }:
{
  services = {
    openssh = {
      enable = true;
      hostKeys =
        if config.hostoptions.impermanence.enable
        then
          [
            {
              path = "/persist/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
            {
              path = "/persist/etc/ssh/ssh_host_rsa_key";
              type = "rsa";
              bits = 4096;
            }
          ]
          else
          [ {
              path = "/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
            {
              path = "/etc/ssh/ssh_host_rsa_key";
              type = "rsa";
              bits = 4096;
            }
          ];
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
