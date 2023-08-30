{ config, lib, outputs, ... }:
let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  pubKey = host: ../../../hosts/${host}/secrets/ssh_host_ed25519_key.pub;
  cfg = config.host.service.ssh;
  logLevel =
    if config.host.network.firewall.fail2ban.enable
    then "VERBOSE"
    else "INFO";
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
      extraConfig = mkOption {
        default = "";
        type = types.lines;
        description = "Verbatim contents of sshd_config";
      };
      harden = mkOption {
        default = false;
        type = with types; bool;
        description = "Harden with more secure settings";
      };
      listenIP = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "IP Address to listen for remote connections";
      };
      listenPort = mkOption {
        type = types.port;
        default = 22;
        description = "Port to listen on";
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
        listenAddresses = [
          {
            addr = mkDefault cfg.listenIP;
            port = mkDefault cfg.listenPort;
          }
        ];
        openFirewall = mkDefault true ;
        startWhenNeeded = mkDefault false;
        settings = {
          GatewayPorts = "clientspecified";
          KbdInteractiveAuthentication = mkDefault true;
          LogLevel = mkDefault logLevel;
          PasswordAuthentication = mkDefault true;
          PermitRootLogin = mkDefault "no" ;
          StreamLocalBindUnlink = "yes";
          X11Forwarding = mkDefault true;
          Ciphers = mkIf cfg.harden [
            "aes256-ctr"
            "aes192-ctr"
            "aes128-ctr"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
            "chacha20-poly1305@openssh.com"
          ];
          KexAlgorithms = mkIf cfg.harden [
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group-exchange-sha256"
            "ecdh-sha2-nistp256"
            "ecdh-sha2-nistp384"
            "ecdh-sha2-nistp521"
          ];
          Macs = mkIf cfg.harden [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "hmac-sha2-512"
            "hmac-sha2-256"
            "umac-128@openssh.com"
            "umac-128-etm@openssh.com"
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

