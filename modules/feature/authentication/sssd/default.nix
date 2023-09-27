{config, lib, pkgs, ...}:

let
  inherit (config.networking) hostName;
  hostsecrets = ../../../../hosts/${hostName}/secrets/sssd.yaml;
  cfg = config.host.feature.authentication.sssd;
  BoolTrueFalse = x:
    if x
    then "true"
    else "false";

    sssdlog =
    if cfg.loglevel.sssd > 0
    then "debug_level = ${toString cfg.loglevel.sssd}"
    else " ";

    nsslog =
    if cfg.loglevel.nss > 0
    then "debug_level = ${toString cfg.loglevel.nss}"
    else " ";

    pamlog =
    if cfg.loglevel.pam > 0
    then "debug_level = ${toString cfg.loglevel.pam}"
    else " ";

    sudolog =
    if cfg.loglevel.sudo > 0
    then "debug_level = ${toString cfg.loglevel.sudo}"
    else " ";

    sshlog =
    if cfg.loglevel.ssh > 0
    then "debug_level = ${toString cfg.loglevel.ssh}"
    else " ";
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
      #SECRET domain = mkOption {
      #SECRET   type = with types; str;
      #SECRET   default = "null";
      #SECRET   description = "Domain Name";
      #SECRET };
      ldap = {
        attribute = {
          sshPublicKey = mkOption {
            default = "sshPublicKey";
            type = with types; str;
            description = "SSH Public Key Attribute";
          };
        };
        #SECRET baseDN = mkOption {
        #SECRET   default = "null";
        #SECRET   type = with types; str;
        #SECRET   description = "Base Distinguished Name";
        #SECRET };
        #SECRET bindDN = mkOption {
        #SECRET   default = "null";
        #SECRET   type = with types; str;
        #SECRET   description = "Bind DN";
        #SECRET };
        #SECRET bindPass = mkOption {
        #SECRET   default = "null";
        #SECRET   type = with types; str;
        #SECRET   description = "Bind Password";
        #SECRET };
        #SECRET filter = {
        #SECRET   access = mkOption {
        #SECRET     default = null;
        #SECRET     type = with types; str;
        #SECRET     description = "Filter to allow user access";
        #SECRET   };
        #SECRET };
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
        #SECRET sudo = {
        #SECRET   searchBase = mkOption {
        #SECRET     default = null;
        #SECRET     type = with types; str;
        #SECRET     description = "Sudo Search Base";
        #SECRET   };
        #SECRET };
        tls = {
          requestCert = mkOption {
            default = "never";
            type = with types; enum ["never" "allow" "try" "demand" "hard"];
            description = "Request TLS Certificate";
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
    environment.etc."nsswitch.conf".text = lib.mkForce ''
      passwd:    files sss systemd
      group:     files sss [success=merge] systemd
      shadow:    files sss
      sudoers:   files sss

      hosts:     mymachines resolve [!UNAVAIL=return] files myhostname dns
      networks:  files

      ethers:    files
      services:  files sss
      protocols: files
      rpc:       files
    '';

    host.filesystem.impermanence.directories = mkIf config.host.filesystem.impermanence.enable [
      "/var/lib/sss"               # SSSD
    ];

    services = {
      sssd = {
        enable = true;
        config = ''
          # This file intentionally blank - See conf.d
        '';
        sshAuthorizedKeysIntegration = true;
      };
      nscd = {
        config = ''
          enable-cache hosts no
          enable-cache passwd no
          enable-cache group no
          enable-cache netgroup no
          enable-cache services no
        '';
        enable = true;
      };
    };

    security = {
      sudo.package = pkgs.sudo.override { withSssd = true; };
      pam.services.systemd-user.makeHomeDir = true;
    };

    ### We switch to SOPS declarations here because we have credentials that need to be secrets
    sops = {
      secrets = {
        "sssd_domain" = { sopsFile = ../../../../hosts/common/secrets/sssd.yaml ; restartUnits = [ "sssd.service" ]; };
        "sssd_ldap_baseDN" = { sopsFile = ../../../../hosts/common/secrets/sssd.yaml ; restartUnits = [ "sssd.service" ]; };
        "sssd_ldap_sudo_searchBase" = { sopsFile = ../../../../hosts/common/secrets/sssd.yaml ; restartUnits = [ "sssd.service" ];};
        "sssd_ldap_uri" = { sopsFile = ../../../../hosts/common/secrets/sssd.yaml ; restartUnits = [ "sssd.service" ];};
        #
        "sssd_ldap_bindDN" = { sopsFile = hostsecrets; restartUnits = [ "sssd.service" ];};
        "sssd_ldap_bindPass" = { sopsFile = hostsecrets; restartUnits = [ "sssd.service" ];};
        "sssd_ldap_filter_access" = { sopsFile = hostsecrets; restartUnits = [ "sssd.service" ];};
      };
      templates = {
        sssd_confd_sssd_conf = {
          name = "sssd/conf.d/sssd.conf";
          path = "/etc/sssd/conf.d/sssd.conf";
          content = ''
            [sssd]
            config_file_version = 2
            services = nss, pam, sudo, ssh
            domains = ${config.sops.placeholder.sssd_domain}
            ${sssdlog}

            [nss]
            ${nsslog}

            [pam]
            ${pamlog}

            [sudo]
            ${sudolog}

            [ssh]
            ${sshlog}

            [domain/${config.sops.placeholder.sssd_domain}]
            id_provider = ldap
            auth_provider = ldap

            ldap_schema = ${cfg.ldap.schema}

            ldap_uri = ${config.sops.placeholder.sssd_ldap_uri}

            ldap_default_bind_dn = ${config.sops.placeholder.sssd_ldap_bindDN}
            ldap_default_authtok = ${config.sops.placeholder.sssd_ldap_bindPass}
            ldap_default_authtok_type = password

            ldap_search_base = ${config.sops.placeholder.sssd_ldap_baseDN}
            ldap_user_object_class = ${cfg.ldap.objectclass.user}

            ldap_tls_reqcert = ${cfg.ldap.tls.requestCert}
            ldap_id_use_start_tls = ${BoolTrueFalse cfg.ldap.tls.useStartTLS}

            cache_credentials = ${BoolTrueFalse cfg.cacheCredentials}
            enumerate = ${BoolTrueFalse cfg.enumerate}

            access_provider = ldap
            ldap_access_filter = ${config.sops.placeholder.sssd_ldap_filter_access}

            sudo_provider = ldap
            ldap_sudo_search_base = ${config.sops.placeholder.sssd_ldap_sudo_searchBase}

            ssh_provider = ldap
            ldap_user_ssh_public_key = ${cfg.ldap.attribute.sshPublicKey}
          '';
        };
      };
    };

    systemd = {
      services.sssd.after = [ "sops-nix.service" ];
      tmpfiles.rules = [
        "L /bin/bash - - - - /run/current-system/sw/bin/bash"  # This is here as a hack for remote systems
      ];
    };
  };
}