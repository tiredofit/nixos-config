{ config, lib, outputs, ... }:
let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  pubKey = host: ../../${host}/secrets/ssh_host_ed25519_key.pub;
in
{
  services = {
    openssh = {
      enable = true;
      hostKeys =
        if config.host.filesystem.impermanence.enable
        then
          [
            {
              path = "/persist/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
          ]
        else
          [ {
              path = "/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
          ];
      settings = {
        PermitRootLogin = "no" ;
        StreamLocalBindUnlink = "yes";
        GatewayPorts = "clientspecified";
      };
    };

    fail2ban.jails = {
      #sshd = ''
      #  enabled = lib.mkForce true
      #  mode = extra
      #'';
      sshd-aggresive = ''
        enabled = lib.mkForce true
        filter = sshd[mode=aggressive]
      '';
    };
  };

  programs.ssh = {
    # Each hosts public key
    knownHosts = builtins.mapAttrs
      (name: _: {
        publicKeyFile = pubKey name;
        extraHostNames =
          (lib.optional (name == hostName) "localhost");
      })
      hosts;
  };
}
