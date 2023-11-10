{config, lib, pkgs, ...}:

let
  container_name = "clamav";
  container_description = "Enables Antivirus scanning container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/clamav";
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
        "/var/local/data/_system/${container_name}/data/clamav:/data"
        "/var/local/data/_system/${container_name}/logs:/logs"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        "DEFINITIONS_UPDATE_FREQUENCY" ="60";
        "ENABLE_ALERT_OLE2_MACROS" = "TRUE";
        "ENABLE_DETECT_PUA" = "FALSE";
        "EXCLUDE_PUA" = "Packed,NetTool,PWTool";
      };
      environmentFiles = [

      ];
      extraOptions = [
        "--memory=2G"
        "--memory-reservation=512M"

        "--network-alias=${hostname}-clamav"
        "--network-alias=clamav-app"
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

    systemd.services."docker-${container_name}" = {
      preStart = ''
        if [ ! -d /var/local/data/_system/${container_name}/logs ]; then
            mkdir -p /var/local/data/_system/${container_name}/logs
            ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/logs
        fi

        ## This one stores its databases as the same filename so lets disable CoW
        if [ ! -d /var/local/data/_system/${container_name}/data ]; then
            mkdir -p /var/local/data/_system/${container_name}/data
            ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/data
        fi
      '';

      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };
  };
}