{ config, lib, outputs, ... }:
let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  pubKey = host: ../../../hosts/${host}/secrets/ssh_host_ed25519_key.pub;
  cfg = config.host.service.ssh;
in
  with lib;
{
  options = {
    host.service.ssh = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable remote accesa via secure shell";
      };
      harden = mkOption {
        default = false;
        type = with types; bool;
        description = "Harden with more secure settings";
      };
    };
  };

  config = mkIf cfg.enable {
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
          PermitRootLogin = mkDefault "no" ;
          StreamLocalBindUnlink = "yes";
          GatewayPorts = "clientspecified";
          KexAlgorithms = mkIf cfg.harden [
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group16-sha512"
            "diffie-hellman-group18-sha512"
            "sntrup761x25519-sha512@openssh.com"
          ];
        };
      };

      fail2ban.jails = mkIf config.host.network.firewall.fail2ban.enable {
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
  };
}

