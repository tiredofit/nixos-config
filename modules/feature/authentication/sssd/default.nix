{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.authentication.sssd;
  BoolTrueFalse = x:
    if x
    then "true"
    else "false";
in
  with lib;
{
  options = {
    host.feature.authentication.sssd = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables ability to authenticate against LDAP servers and control sudo privileges";
      };
      cacheCredentials = mkOption {
        default = false;
        type = with types; bool;
        description = "Cache Credentials";
      };
      enumerate = mkOption {
        default = false;
        type = with types; bool;
        description = "Enumerate users in /etc/passwd and /etc/group";
      };
      domain = mkOption {
        type = with types; str;
        default = "null";
        description = "Domain Name";
      };
      ldap = {
        attribute = {
          sshPublicKey = mkOption {
            default = "sshPublicKey";
            type = with types; str;
            description = "SSH Public Key Attribute";
          };
        };
        baseDN = mkOption {
          default = "null";
          type = with types; str;
          description = "Base Distinguished Name";
        };
        bindDN = mkOption {
          default = "null";
          type = with types; str;
          description = "Bind DN";
        };
        bindPass = mkOption {
          default = "null";
          type = with types; str;
          description = "Bind Password";
        };
        filter = {
          access = mkOption {
            default = null;
            type = with types; str;
            description = "Filter to allow user access";
          };
        };
        objectclass = {
          user = mkOption {
            default = "inetOrgPerson";
            type = with types; str;
            description = "User Object Class";
          };
        };
        schema = mkOption {
          default = "rfc2307bis";
          type = types.enum ["nis" "rfc2307bis"];
          description = "Schema Type";
        };
        sudo = {
          searchBase = mkOption {
            default = null;
            type = with types; str;
            description = "Sudo Search Base";
          };
        };
        tls = {
          requestCert = mkOption {
            default = "try";
            type = with types; enum ["never" "allow" "try" "demand" "hard"];
            description = "Requtest TLS Certificate";
          };
          useStartTLS = mkOption {
            default = false;
            type = with types; bool;
            description = "Use StartTLS";
          };
        };
        uri = mkOption {
          type = with types; str;
          description = "URI of LDAP Host";
        };
      };

      loglevel = {
        sssd = mkOption {
          default = 2;
          type = with types; int;
          description = "SSSD Log Level 0-9";
        };
        nss = mkOption {
          default = cfg.loglevel.sssd;
          type = with types; int;
          description = "NSS Log Level 0-9";
        };
        pam = mkOption {
          default = cfg.loglevel.sssd;
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
    services = {
      sssd = {
        enable = true;
        config = ''
[domain/${cfg.domain}]
id_provider = ldap
auth_provider = ldap

ldap_schema = ${cfg.ldap.schema}

ldap_uri = ${cfg.ldap.uri}

ldap_default_bind_dn = ${cfg.ldap.bindDN}
ldap_default_authtok = ${cfg.ldap.bindPass}
ldap_default_authtok_type = password

ldap_search_base = ${cfg.ldap.baseDN}
ldap_user_object_class = ${cfg.ldap.objectclass.user}

ldap_tls_reqcert = ${cfg.ldap.tls.requestCert}
ldap_id_use_start_tls = ${BoolTrueFalse cfg.ldap.tls.useStartTLS}

cache_credentials = ${BoolTrueFalse cfg.cacheCredentials}
enumerate = ${BoolTrueFalse cfg.enumerate}

access_provider = ldap
ldap_access_filter = ${cfg.ldap.filter.access}

sudo_provider = ldap
ldap_sudo_search_base = ${cfg.ldap.sudo.searchBase}

ldap_user_ssh_public_key = ${cfg.ldap.attribute.sshPublicKey}

[sssd]
config_file_version = 2
services = nss, pam, sudo, ssh
domains = ${cfg.domain}
debug_level = ${toString cfg.loglevel.sssd}

[nss]
debug_level = ${toString cfg.loglevel.nss}

[pam]
debug_level = ${toString cfg.loglevel.pam}

[sudo]
debug_level = ${toString cfg.loglevel.sudo}

[ssh]
debug_level = ${toString cfg.loglevel.ssh}
        '';
        sshAuthorizedKeysIntegration = true;
      };
      nscd.config = ''
        enable-cache hosts yes
        enable-cache passwd no
        enable-cache group no
        enable-cache netgroup no
        enable-cache services no
      '';
    };

    security = {
      sudo.package = pkgs.sudo.override { withSssd = true; };
      pam.services.systemd-user.makeHomeDir = true;
    };

    systemd.tmpfiles.rules = [
      "L /bin/bash - - - - /run/current-system/sw/bin/bash"  # This is here as a hack for remote systems
    ];
  };
}