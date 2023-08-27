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
          Ciphers = mkIf cfg.harden [
           "chacha20-poly1305@openssh.com"
           "aes256-gcm@openssh.com"
           "aes128-gcm@openssh.com"
           "aes256-ctr"
           "aes192-ctr"
           "aes128-ctr"
          ];
          KexAlgorithms = mkIf cfg.harden [
            "curve25519-sha256@libssh.org"
            "ecdh-sha2-nistp521"
            "ecdh-sha2-nistp384"
            "ecdh-sha2-nistp256"
            "diffie-hellman-group-exchange-sha256"
            "curve25519-sha256"
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group16-sha512"
            "diffie-hellman-group18-sha512"
            "sntrup761x25519-sha512@openssh.com"
          ];
          Macs = mkIf cfg.harden [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
            "hmac-sha2-512"
            "hmac-sha2-256"
            "umac-128@openssh.com"
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

