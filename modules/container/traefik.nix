{config, lib, pkgs, ...}:

let
  container_name = "traefik";
  container_description = "Enables reverse proxy container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/traefik";
  container_image_tag = "2.11";
  tcc_container_name = "cloudflare-companion";
  tcc_container_description = "Enables ability to create CNAMEs with traefik container";
  tcc_container_image_registry = "docker.io";
  tcc_container_image_name = "tiredofit/traefik-cloudflare-companion";
  tcc_container_image_tag = "latest";

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
    };

    host.container.${tcc_container_name} = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = tcc_container_description;
      };
      image = {
        name = mkOption {
          default = tcc_container_image_name;
          type = with types; str;
          description = "Image name";
        };
        tag = mkOption {
          default = tcc_container_image_tag;
          type = with types; str;
          description = "Image tag";
        };
        registry = {
          host = mkOption {
            default = tcc_container_image_registry;
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
    };
  };

  config = mkIf cfg.enable {
    host.feature.virtualization.docker.containers."${container_name}" = {
      image = "${cfg.image.name}:${cfg.image.tag}";
      ports = [
        "80:80"
        "443:443"
      ];
      volumes = [
        "/var/local/data/_system/${container_name}/certs:/data/certs"
        "/var/local/data/_system/${container_name}/config:/data/config"
        "/var/local/data/_system/${container_name}/logs:/data/logs"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        "DOCKER_ENDPOINT" = "http://socket-proxy:2375";
        "LOG_LEVEL" = "WARN";
        "ACCESS_LOG_TYPE" = "FILE";
        "LOG_TYPE" = "FILE";
        "TRAEFIK_USER" = "traefik";
        "LETSENCRYPT_CHALLENGE" = "DNS";
        "LETSENCRYPT_DNS_PROVIDER" = "cloudflare";

        #"LETSENCRYPT_EMAIL" = "common_env";                                            # hosts/common/secrets/container-traefik.env
        #"CF_API_EMAIL" = "1234567890";                                                 # hosts/common/secrets/container-traefik.env
        #"CF_API_KEY" = "1234567890";                                                   # hosts/common/secrets/container-traefik.env
        "DASHBOARD_HOSTNAME" = "${hostname}.vpn.${config.host.network.domainname}";     # hosts/common/secrets/container-traefik.env
      };
      environmentFiles = [
        config.sops.secrets."common-container-${container_name}".path
      ];
      extraOptions = [
        "--hostname=${hostname}.vpn.${config.host.network.domainname}"
        "--cpus=0.5"
        "--memory=256M"
        "--network-alias=${hostname}-${container_name}"
      ];
      networks = [
        "proxy"
        "services"
        "socket-proxy"
      ];
      autoStart = mkDefault true;
      log-driver = mkDefault "local";
      login = {
        registry = cfg.image.registry.host;
      };
    };

    sops.secrets = {
      "common-container-${container_name}" = {
        format = "dotenv";
        sopsFile = ../../hosts/common/secrets/container/container-${container_name}.env;
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

    host.feature.virtualization.docker.containers."${tcc_container_name}" = mkIf config.host.container.${tcc_container_name}.enable {
      image = "${config.host.container.${tcc_container_name}.image.name}:${config.host.container.${tcc_container_name}.image.tag}";
      volumes = [
        "/var/local/data/_system/${container_name}/logs/tcc:/logs"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${tcc_container_name}";
        "CONTAINER_ENABLE_MONITORING" = config.host.container."${tcc_container_name}".monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = config.host.container."${tcc_container_name}".logship;

        "DOCKER_HOST" = "http://socket-proxy:2375";
        "TRAEFIK_VERSION" = "2";
        "TARGET_DOMAIN" = "${hostname}.${config.host.network.domainname}";

        #"CF_EMAIL" = "email@example.com";  # hosts/common/secrets/container-traefik-cloudflare-companion.env
        #"CF_TOKEN" = "1234567890";         # hosts/common/secrets/container-traefik-cloudflare-companion.env

        #"DOMAIN1" = "example.com";         # hosts/common/secrets/container-traefik-cloudflare-companion.env
        #"DOMAIN1_ZONE_ID" = "abc";         # hosts/common/secrets/container-traefik-cloudflare-companion.env
      };
      environmentFiles = [
        config.sops.secrets."common-container-${tcc_container_name}".path
      ];
      extraOptions = [
        "--hostname=${hostname}.vpn.${config.host.network.domainname}"
        "--cpus=0.25"
        "--memory=128M"
        "--network-alias=${hostname}-${tcc_container_name}"
      ];
      networks = [
        "services"
        "socket-proxy"
      ];
      autoStart = mkDefault true;
      log-driver = mkDefault "local";
      login = {
        registry = config.host.container."${tcc_container_name}".image.registry.host;
      };
      pullonStart = config.host.container."${tcc_container_name}".image.update;
    };

    sops.secrets = {
      "common-container-${tcc_container_name}" = {
        format = "dotenv";
        sopsFile = ../../hosts/common/secrets/container/container-${container_name}-${tcc_container_name}.env;
        restartUnits = [ "docker-${tcc_container_name}.service" ];
      };
    };

    systemd.services."docker-${tcc_container_name}" = mkIf config.host.container.${tcc_container_name}.enable {
      preStart = ''
        if [ ! -d /var/local/data/_system/${container_name}/logs/tcc ]; then
            mkdir -p /var/local/data/_system/${container_name}/logs/tcc
            ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/logs/tcc
        fi
      '';

      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };
  };
}