{config, lib, pkgs, ...}:

let
  container_name = "openldap";
  container_description = "Enables directory services container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/openldap-fusiondirectory";
  container_image_tag = "2.6-1.4";
  cfg = config.host.container.${container_name};
  hostname = config.host.network.hostname;
  activationScript = "system.activationScripts.docker_${container_name}";
in
  with lib;
{
  options = {
    host.container.${container_name} = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = container_description;
      };
      image = {
        name = mkOption {
          default = container_image_name;
          type = with types; str;
          description = "Image name";
        };
        tag = mkOption {
          default = container_image_tag;
          type = with types; str;
          description = "Image tag";
        };
        registry = {
          host = mkOption {
            default = container_image_registry;
            type = with types; str;
            description = "Image Registry";
          };
        };
        update = mkOption {
          default = true;
          type = with types; bool;
          description = "Pull image on each service start";
        };
      };
      logship = mkOption {
        default = "true";
        type = with types; str;
        description = "Enable monitoring for this container";
      };
      monitor = mkOption {
        default = "true";
        type = with types; str;
        description = "Enable monitoring for this container";
      };
      option = {
        hostname_tld = mkOption {
          type = with types; str;
          description = "Hostname and TLD";
        };
        listen_ip = mkOption {
          type = with types; str;
          description = "Listen IP for unencrypted communications";
        };
        listen_ip_tls = mkOption {
          type = with types; str;
          description = "Listen IP for encrypted communications";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    host.feature.virtualization.docker.containers."${container_name}" = {
      image = "${cfg.image.name}:${cfg.image.tag}";
      ports = [
        "${cfg.option.internal_ip}:389:389"
        "${cfg.option.internal_ip_tls}:636:636"
      ];
      volumes = [
        "/var/local/data/_system/${container_name}/assets:/assets/custom-plugins:/assets/fusiondirectory-custom"
        "/var/local/data/_system/${container_name}/backup:/data/backup"
        "/var/local/data/_system/${container_name}/certs:/certs"
        "/var/local/data/_system/${container_name}/config:/etc/openldap/slapd.d"
        "/var/local/data/_system/${container_name}/data:/var/lib/openldap"
        "/var/local/data/_system/${container_name}/logs:/logs"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        "HOSTNAME" = cfg.option.hostname_tld;       # Technically this could be but you also need to set --hostname below

        #"DEBUG_MODE" = "FALSE";                    # hosts/<hostname>/secrets/container-openldap.env
        #"LOG_LEVEL"= "0";                          # hosts/<hostname>/secrets/container-openldap.env
        #"LOG_TYPE"= "FILE";                        # hosts/<hostname>/secrets/container-openldap.env

        #"ORGANIZATION" = "Example Name";           # hosts/<hostname>/secrets/container-openldap.env
        #"DOMAIN" = "example.com";                  # hosts/<hostname>/secrets/container-openldap.env
        #"BASE_DN" = "dc=example,dc=com";           # hosts/<hostname>/secrets/container-openldap.env
        #"SCHEMA_TYPE"= "nis";                      # hosts/<hostname>/secrets/container-openldap.env

        #"ADMIN_PASS" = "admin_password";           # hosts/<hostname>/secrets/container-openldap.env
        #"CONFIG_PASS"= "config_password";          # hosts/<hostname>/secrets/container-openldap.env

        #"PLUGIN_AUDIT" = "TRUE";                   # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_DNS" = "TRUE";                     # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_DSA" = "TRUE";                     # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_KOPANO" = "TRUE";                  # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_MAIL" = "FALSE";                   # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_MIXEDGROUPS" = "FALSE";            # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_PERSONAL" = "TRUE";                # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_POSIX" = "TRUE";                   # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_PPOLICY" = "TRUE";                 # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_SSH" = "TRUE";                     # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_SUDO" = "TRUE";                    # hosts/<hostname>/secrets/container-openldap.env
        #"PLUGIN_SYSTEMS" =" TRUE";                 # hosts/<hostname>/secrets/container-openldap.env
        #"REAPPLY_PLUGIN_SCHEMAS"= "FALSE";         # hosts/<hostname>/secrets/container-openldap.env

        #"ENABLE_REPLICATION" = "FALSE";
        #"REPLICATION_CONFIG_SYNCPROV" = "binddn='cn=admin,cn=config' bindmethod=simple credentials='config_password' searchbase='cn=config' type=refreshAndPersist retry='5 5 300 +' timeout=1";
        #"REPLICATION_DB_SYNCPROV" = "binddn='cn=admin,dc=example,dc=com' bindmethod=simple credentials='admin_password' searchbase='dc=example,dc=com' type=refreshAndPersist interval=00:00:00:10 retry='5 5 300 +' timeout=1";
        #"REPLICATION_HOSTS" = "ldap://ldap.example.com ldap://ldap2.example.com";

        #"ENABLE_TLS" = "TRUE";                     # hosts/<hostname>/secrets/container-openldap.env

        #"BACKUP_BEGIN"= "+0";                      # hosts/<hostname>/secrets/container-openldap.env
        #"BACKUP_INTERVAL"= "60";                   # hosts/<hostname>/secrets/container-openldap.env
        #"BACKUP_ARCHIVE_TIME"= "59";               # hosts/<hostname>/secrets/container-openldap.env

        #"PPOLICY_MIN_DIGIT" = "1";                 # hosts/<hostname>/secrets/container-openldap.env
        #"PPOLICY_MIN_LOWER" = "1";                 # hosts/<hostname>/secrets/container-openldap.env
        #"PPOLICY_MIN_UPPER" = "1";                 # hosts/<hostname>/secrets/container-openldap.env
        #"PPOLICY_MIN_PUNCT" = "1";                 # hosts/<hostname>/secrets/container-openldap.env
        #"PPOLICY_MIN_POINTS" = "4";                # hosts/<hostname>/secrets/container-openldap.env
      };
      environmentFiles = [
        config.sops.secrets."host-container-${container_name}".path
      ];
      extraOptions = [
        "--memory=4G"

        "--hostname=${cfg.option.hostname_tld}"
        "--network-alias=${hostname}-${container_name}"
      ];
      networks = [
        "services"
      ];
      autoStart = mkDefault true;
      log-driver = mkDefault "local";
      login = {
        registry = cfg.image.registry.host;
      };
      pullonStart = cfg.image.update;
    };

    sops.secrets = {
      "host-container-${container_name}" = {
        format = "dotenv";
        sopsFile = ../../hosts/${hostname}/secrets/container/container-${container_name}.env;
        restartUnits = [ "docker-${container_name}.service" ];
      };
    };

    systemd.services."docker-${container_name}" = {
      preStart = ''
        if [ ! -d /var/local/data/_system/${container_name}/logs ]; then
            mkdir -p /var/local/data/_system/${container_name}/logs
            ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/logs
        fi
      '';

      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };
  };
}