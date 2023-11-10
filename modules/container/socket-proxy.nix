{config, lib, pkgs, ...}:

let
  container_name = "socket-proxy";
  container_description = "Enables docker.sock proxy container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/socket-proxy";
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
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/local/data/_system/${container_name}/logs:/logs"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        "ALLOWED_IPS" = "127.0.0.1,172.19.192.0/18";
        "ENABLE_READONLY" = "TRUE";
        "MODE" = "containers,events,networks,ping,services,tasks,version";
      };
      environmentFiles = [

      ];
      extraOptions = [
        "--cpus=0.000"
        "--memory=100M"
        "--memory-reservation=32M"
        "--network-alias=${hostname}-socket-proxy"
      ];
      networks = [
        "socket-proxy"
      ];

      autoStart = mkDefault true;
      log-driver = mkDefault "local";
      login = {
        registry = cfg.image.registry.host;
      };
      pullonStart = cfg.image.update;
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