{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.authentication.sssd;
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
        default = true;
        type = with types; bool;
        description = "Cache Credentials";
      };
      enumerate = mkOption {
        default = false;
        type = with types; bool;
        description = "Enumerate users in /etc/passwd and /etc/group";
      };
      ldap ={
        attribute = {
          sshPublicKey = {
            default = "sshPublicKey";
            type = with types; string;
            description = "SSH Public Key Attribute";
          };
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
        bindPass = {
          default = null;
          type = with types; string;
          description = "Bind Password";
        };
        domain = {
          type = with types; string;
          description = "Domain Name";
        };
        filter = {
          access = {
            default = null;
            type = with types; string;
            description = "Filter to allow user access";
          };
        };
        objectclass = {
          user = {
            default = "inetOrgPerson";
            type = with types; string;
            description = "User Object Class";
          };
        };
        schema = {
          default = "rfc2307bis";
          type = types.enum ["nis" "rfc2307bis"];
          description = "Schema Type";
        };
        sudo = {
          searchBase = {
            default = null;
            type = with types; string;
            description = "Sudo Search Base";
          };
        };
        uri = {
          type = with types; string;
          description = "URI of LDAP Host";
        };
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
    services = {
      sssd = {
        enable = true;
        config = ''
[domain/${domain}]
id_provider = ldap
auth_provider = ldap

ldap_schema = ${cfg.ldap.schema}

ldap_uri = ${cfg.ldap.uri}

ldap_default_bind_dn = ${cfg.ldap.bindDN}
ldap_default_authtok = ${cfg.ldap.bindPass}
ldap_default_authtok_type = password

ldap_search_base = ${cfg.ldap.baseDN}
ldap_user_object_class = ${cfg.ldap.objectclass.user}

ldap_tls_reqcert = never
ldap_id_use_start_tls = false

cache_credentials = ${cfg.cacheCredentials}
enumerate = ${cfg.enumerate}

access_provider = ldap
ldap_access_filter = ${cfg.ldap.filter.access}

sudo_provider = ldap
ldap_sudo_search_base = ${cfg.ldap.sudo.searchBase}

ldap_user_ssh_public_key = ${cfg.ldap.sshPublicKey}

[sssd]
config_file_version = 2
services = nss, pam, sudo, ssh
domains = ${cfg.domain}
debug_level = ${cfg.loglevel.sssd}

[nss]
debug_level = ${cfg.loglevel.nss}

[pam]
debug_level = ${cfg.loglevel.pam}

[sudo]
debug_level = ${cfg.loglevel.sudo}

[ssh]
debug_level = ${cfg.loglevel.ssh}

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

    systemd.tmpfiles.rules = [
      "L /bin/bash - - - - /run/current-system/sw/bin/bash"  # This is here as a hack for remote systems
    ];

    security.pam.services.systemd-user.makeHomeDir = true;
  };
}
