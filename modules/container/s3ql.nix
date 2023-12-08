{config, lib, pkgs, ...}:

let
  container_name = "s3ql";
  container_description = "Enables S3QL mounted filesystem";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/s3ql";
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
        "/var/local/data/_system/${container_name}/config:/config"
        "/var/local/data/_system/${container_name}/cache:/cache"
        "/var/local/data/_system/${container_name}/logs:/logs"
        "/mnt/s3ql:/data:shared"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        #"MODE" = "normal";
        #
        #"S3_HOST" = "s3c://s3.region.wasabisys.com:443/bucket";
        #"S3_KEY_ID" = "id";
        #"S3_KEY_SECRET" = "secret";
        #"S3QL_PASS" = "abcdefgh";
        #
        #"ENABLE_CACHE" = "TRUE";
        #"ENABLE_PERSISTENT_CACHE" = "TRUE";
        #"COMPRESSION"= "none";
        #"LOG_TYPE" = "FILE";
        #"DEBUG_MODE" = "FALSE";

      };
      environmentFiles = [
        config.sops.secrets."host-container-${container_name}".path
      ];
      extraOptions = [
        #"--memory=256M" ## TODO: Map
        "--network-alias=${hostname}-${container_name}"
        "--pull=always"
        "--cap-add=SYS_ADMIN"
        "--device=/dev/net/tun"
        "--privileged"
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

        ## This one stores cache in here so lets disable CoW
        if [ ! -d /var/local/data/_system/${container_name}/cache ]; then
            mkdir -p /var/local/data/_system/${container_name}/cache
            ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/cache
        fi
      '';

      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };
  };
}