{config, lib, pkgs, ...}:

let
  container_name = "tinc";
  container_description = "Enables VPN container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/tinc";
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
        "/var/local/data/_system/${container_name}/data:/etc/tinc"
        "/var/local/data/_system/${container_name}/logs:/var/log/tinc"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        #"FLUENTBIT_OUTPUT_FORWARD_HOST" = "127.0.0.1";     # hosts/common/secrets/container-tinc.env
        #"INTERFACE" = "tun0";                              # hosts/common/secrets/container-tinc.env

        #"COMPRESSION"= "0";                                # hosts/common/secrets/container-tinc.env
        #"CRON_PERIOD" = "15";                              # hosts/common/secrets/container-tinc.env
        #"DEBUG" = "0";                                     # hosts/common/secrets/container-tinc.env


        #"ZABBIX_SERVER" = "172.16.0.0/12";                 # hosts/common/secrets/container-tinc.env
        #"ZABBIX_SERVER_ACTIVE" = "zabbix.example.com";     # hosts/common/secrets/container-tinc.env
        #"ZABBIX_LISTEN_PORT"= "10056";                     # hosts/common/secrets/container-tinc.env
        #"ZABBIX_STATUS_PORT"= "8056";                      # hosts/common/secrets/container-tinc.env

        #"NETWORK" ="network_name";                         # hosts/common/secrets/container-tinc.env
        #"PEERS"= "node1_example_com node2_example_com";    # hosts/common/secrets/container-tinc.env


        #"GIT_USER"= "username";                            # hosts/<hostname>/secrets/container-tinc.env
        #"GIT_PASS"= "password";                            # hosts/<hostname>/secrets/container-tinc.env

        #"ENABLE_WATCHDOG" = "TRUE";                        # hosts/<hostname>/secrets/container-tinc.env
        #"WATCHDOG_HOST" = "host_env";                      # hosts/<hostname>/secrets/container-tinc.env
        #"NODE"= "host_env";                                # hosts/<hostname>/secrets/container-tinc.env
        #"PUBLIC_IP"= "host_env";                           # hosts/<hostname>/secrets/container-tinc.env
        #"PRIVATE_IP"= "host_env";                          # hosts/<hostname>/secrets/container-tinc.env
      };
      environmentFiles = [
        config.sops.secrets."common-container-${container_name}".path
        config.sops.secrets."host-container-${container_name}".path
      ];
      extraOptions = [
        "--hostname=${hostname}.vpn.${config.host.network.domainname}"
        "--cpus=0.5"
        "--memory=256M" ## TODO: Map
        "--cap-add=SYS_ADMIN"
        "--device=/dev/net/tun"
        "--privileged"
      #  "--network=host"
      ];
      networks = [ "host" ];
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