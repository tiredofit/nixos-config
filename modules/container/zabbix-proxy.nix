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
        zabbix_proxy_listen_port = mkOption {
          default = "10051";
          type = with types; str;
          description = "Zabbix Proxy Listening Port";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    host.feature.virtualization.docker.containers."${container_name}" = {
      image = "${cfg.image.name}:${cfg.image.tag}";
      volumes = [
        "/var/local/data/_system/${container_name}/logs:/var/log/zabbix/proxy"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        #"ZABBIX_PROXY_SERVER" = "zabbix.example.com";                    # hosts/common/secrets/container-zabbix-proxy.env
        #"ZABBIX_PROXY_SERVER_PORT" = "10051";                            # hosts/common/secrets/container-zabbix-proxy.env
        "ZABBIX_PROXY_LISTEN_PORT" = cfg.option.zabbix_proxy_listen_port;
      };
      environmentFiles = [
        config.sops.secrets."common-container-${container_name}".path
      ];
      extraOptions = [
        "--cpus=0.5"
        "--memory=256M"

        "--dns=172.19.153.53"
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
  };
}