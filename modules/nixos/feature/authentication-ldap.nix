{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.authentication.ldap;
in
  with lib;
{
  options = {
    host.feature.authentication.ldap = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables ability to authenticate against LDAP servers";
      };
      baseDN = {
        default = null;
        type = with types; string;
        description = "Base Distinguished Name";
      };
      bindDN = {
        default = null;
        type = with types; string;
        description = "Bind DN";
      };
      bindPassFile = {
        default = null;
        type = with types; string;
        description = "Bind Password";
      };
      uri = {
        default = null;
        type = with types; string;
        description = "URI of LDAP Host";
      };
      tls = {
        default = false;
        type = with types; bool;
        description = "Use TLS";
      };

      loglevel = {
        sssd = mkOption {
          default = false;
          type = with types; int;
          description = "SSSD Log Level 0-9";
        };
        nss = mkOption {
          default = cfg.loglevel.sssd;
          type = with types; int;
          description = "NSS Log Level 0-9";
        };
        pam = mkOption {
          default = cfg.loglevel.pam;
          type = with types; int;
          description = "PAM Log Level 0-9";
        };
        ssh = mkOption {
          default = cfg.loglevel.sssd;
          type = with types; int;
          description = "SSH Log Level 0-9";
        };
        sudo = mkOption {
          default = cfg.loglevel.sssd;
          type = with types; int;
          description = "Sudo Log Level 0-9";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users.ldap = {
      enable = true;
      base = "${cfg.baseDN}";
      bind = {
        distinguishedName = "${cfg.bindDN}";
        passwordFile = "${cfg.bindPassFile}";
      };
      loginPam = mkDefault.true;
      server = "${cfg.uri}";
      timeLimit = mkDefault 30;
      useTLS = cfg.tls;
      extraConfig = ''
        ldap_version 3
        pam_password md5
      '';
    };

    security.pam.services = {
      sshd.makeHomeDir = true;
      gdm-launch-environment.makeHomeDir = true;
      login.makeHomeDir = true;
      systemd-user.makeHomeDir = true;
    };

    systemd.services.nslcd = mkIf config.networking.networkmanager.enable {
      after = [ "Network-Manager.service" ];
    };

    systemd.tmpfiles.rules = [
        "L /bin/bash - - - - /run/current-system/sw/bin/bash"  # This is a hack
    ];
  };
}
