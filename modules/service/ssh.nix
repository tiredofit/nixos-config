{ config, lib, pkgs, outputs, ... }:
let
  inherit (config.networking) hostName;
  hosts = outputs.nixosConfigurations;
  pubKey = host: ../../hosts/${host}/secrets/ssh_host_ed25519_key.pub;
  cfg = config.host.service.ssh;
  logLevel =
    if config.host.network.firewall.fail2ban.enable
    then "VERBOSE"
    else "INFO";

  authMethods =
    if config.host.service.ssh.passwordlessLogin
    then "publickey password keyboard-interactive"
    else "publickey,password publickey,keyboard-interactive";
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
      passwordlessLogin = mkOption {
        default = true;
        type = with types; bool;
        description = "Enable Passwordless login, relying only on keys";
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
          AuthenticationMethods = mkDefault authMethods;
          AcceptEnv = "LANG LC_*";
          ChallengeResponseAuthentication = mkDefault true;
          Ciphers = mkIf cfg.harden [
            "aes256-ctr"
            "aes192-ctr"
            "aes128-ctr"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
            "chacha20-poly1305@openssh.com"
          ];
          GatewayPorts = mkDefault "clientspecified";
          KbdInteractiveAuthentication = mkDefault true;
          KexAlgorithms = mkIf cfg.harden [
            "curve25519-sha256@libssh.org"
            "diffie-hellman-group-exchange-sha256"
            "ecdh-sha2-nistp256"
            "ecdh-sha2-nistp384"
            "ecdh-sha2-nistp521"
          ];
          LoginGraceTime = mkDefault "45s";
          LogLevel = mkDefault logLevel;
          MaxAuthTries = mkDefault 4;
          Macs = mkIf cfg.harden [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "hmac-sha2-512"
            "hmac-sha2-256"
            "umac-128@openssh.com"
            "umac-128-etm@openssh.com"
          ];
          PasswordAuthentication = mkDefault true;
          PermitRootLogin = mkDefault "no" ;
          PermitTunnel = mkDefault true;
          PermitTTY = mkDefault true;
          PrintLastLog = mkDefault true;
          PubkeyAuthentication = mkDefault true;
          RekeyLimit = mkDefault "default 1d";
          StreamLocalBindUnlink = mkDefault true;
          TCPKeepAlive = mkDefault true;
          X11Forwarding = mkDefault true;
          X11UseLocalHost = mkDefault true;
          X11DisplayOffset = mkDefault 10;
        };
        extraConfig = ''
        '';
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

    systemd.services.sshd.preStart = ''
      ## This is in here when doing a remote install and rsyncing keys over as a regular user the permissions can get wonky.
      if [ -d "/persist/etc/ssh/" ]; then
        path_prefix=/persist/
      fi

      pri=$(stat -c "%a %U %G" "$path_prefix"/etc/ssh/ssh_host_ed25519_key)
      pub=$(stat -c "%a %U %G" "$path_prefix"/etc/ssh/ssh_host_ed25519_key.pub)

      if [ $(echo "$pri" | ${pkgs.gawk}/bin/awk '{print $1}') != 600 ]; then
        echo "Resetting Permissions on SSH Host Private Key"
        chmod 600 "$path_prefix"/etc/ssh/ssh_host_ed25519_key
      fi

      if [ $(echo "$pri" | ${pkgs.gawk}/bin/awk '{print $2}') != "root" ]; then
        chown root:root "$path_prefix"/etc/ssh/ssh_host_ed25519_key
      fi

      if [ $(echo "$pub" | ${pkgs.gawk}/bin/awk '{print $1}') != 640 ]; then
        echo "Resetting Permissions on SSH Host Public Key"
        chmod 640 "$path_prefix"/etc/ssh/ssh_host_ed25519_key.pub
      fi

      if [ "$(echo "$pub" | ${pkgs.gawk}/bin/awk '{print $2" "$3}')" != "root root" ]; then
          echo "Resetting ownership on SSH Host Public Key"
          chown -R root:root "$path_prefix"/etc/ssh/ssh_host_ed25519_key.pub
      fi
    '';
  };
}

