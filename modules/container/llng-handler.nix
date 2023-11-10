{config, lib, pkgs, ...}:

let
  container_name = "llng-handler";
  container_description = "Enables authentication handling container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/lemonldap";
  container_image_tag = "latest";
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
  };

  config = mkIf cfg.enable {
    host.feature.virtualization.docker.containers."${container_name}" = {
      image = "${cfg.image.name}:${cfg.image.tag}";
      labels = {
        "traefik.enable" = "true";
        "traefik.http.routers.${hostname}-${container_name}.rule" = "Host(`${hostname}.handler.auth.${config.host.network.domainname}`)";
        "traefik.http.services.${hostname}-${container_name}.loadbalancer.server.port" = "80";
      };
      volumes = [
        "/var/local/data/_system/${container_name}/logs:/www/logs"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        #"DOMAIN_NAME" = config.host.network.domainname;                  # hosts/common/secrets/container-llng-handler.env
        #"HANDLER_HOSTNAME" = "${hostname}.handler.auth.example.com";     # hosts/common/secrets/container-llng-handler.env
        #"HANDLER_ALLOWED_IPS"= "172.16.0.0/12,127.0.01";                 # hosts/common/secrets/container-llng-handler.env

        #"CONFIG_TYPE=REST";                                              # hosts/common/secrets/container-llng-handler.env
        #"REST_HOST" = "https://auth.example.com/index.psgi/config";      # hosts/common/secrets/container-llng-handler.env
        #"REST_USER" = "user";                                            # hosts/<hostname>/secrets/container-llng-handler.env
        #"REST_PASS" = "password";                                        # hosts/<hostname>/secrets/container-llng-handler.env
      };
      environmentFiles = [
        config.sops.secrets."common-container-${container_name}".path
        config.sops.secrets."host-container-${container_name}".path
      ];
      extraOptions = [
        "--memory=512M"
        "--network-alias=${hostname}-${container_name}"
      ];
      networks = [
        "proxy"
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
      "common-container-${container_name}" = {
        format = "dotenv";
        sopsFile = ../../hosts/common/secrets/container/container-${container_name}.env;
        restartUnits = [ "docker-${container_name}.service" ];
      };
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