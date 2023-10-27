{config, lib, pkgs, ...}:

let
  container_name = "zabbix-proxy";
  container_description = "Enables Zabbix proxy monitoring container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/zabbix";
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
      };
      logship = mkOption {
        default = "false";
        type = with types; str;
        description = "Enable monitoring for this container";
      };
      monitor = mkOption {
        default = "false";
        type = with types; str;
        description = "Enable monitoring for this container";
      };
      option = {
        zabbix_proxy_listen_port = mkOption {
          default = "10051";
          type = with types; str;
          description = "Zabbix Proxy Listening Port";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "common-container-${container_name}" = {
        format = "dotenv";
        sopsFile = ../../hosts/common/secrets/container-${container_name}.env;
      };
    };
    system.activationScripts."docker_${container_name}" = ''
        if [ ! -d /var/local/data/_system/${container_name}/logs ]; then
            mkdir -p /var/local/data/_system/${container_name}/logs
            ${pkgs.e2fsprogs}/bin/chattr +C /var/local/data/_system/${container_name}/logs
        fi
      '';

    systemd.services."docker-${container_name}" = {
      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };

    virtualisation.oci-containers.containers."${container_name}" = {
      image = "${cfg.image.name}:${cfg.image.tag}";
      volumes = [
        "/var/local/data/_system/${container_name}/logs:/var/log/zabbix/proxy"
      ];
      environment = {
      "TIMEZONE" = "America/Vancouver";
      "CONTAINER_NAME" = "${hostname}-${container_name}";
      "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
      "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

      #"ZABBIX_PROXY_SERVER" = "zabbix.example.com";
      #"ZABBIX_PROXY_SERVER_PORT" = "10051";
      "ZABBIX_PROXY_LISTEN_PORT" = cfg.option.zabbix_proxy_listen_port;
      };
      environmentFiles = [

      ];
      extraOptions = [
        "--cpus=0.5"
        "--memory=256M"
        "--network=services"
        "--network-alias=${hostname}-${container_name}"
      ];

      autoStart = mkDefault true;
      log-driver = mkDefault "local";
      login = {
        registry = cfg.image.registry.host;
      };
    };
  };
}