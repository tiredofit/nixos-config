{config, lib, pkgs, ...}:

let
  container_name = "restic";
  container_description = "Enables Backup container";
  container_image_registry = "docker.io";
  container_image_name = "tiredofit/restic";
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
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "host-container-${container_name}" = {
        format = "dotenv";
        sopsFile = ../../hosts/${hostname}/secrets/container-${container_name}.env;
      };
    };

    system.activationScripts."docker_${container_name}" = ''
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

    systemd.services."docker-${container_name}" = {
      serviceConfig = {
        StandardOutput = "null";
        StandardError = "null";
      };
    };

    virtualisation.oci-containers.containers."${container_name}" = {
      image = "${cfg.image.name}:${cfg.image.tag}";
      volumes = [
        "/var/local/data/_system/${container_name}/cache:/cache"
        "/var/local/data/_system/${container_name}/logs:/logs"
        "/var/local/data/_system/${container_name}/restore:/restore"
        "/:/rootfs:ro"
      ];
      environment = {
        "TIMEZONE" = "America/Vancouver";
        "CONTAINER_NAME" = "${hostname}-${container_name}";
        "CONTAINER_ENABLE_MONITORING" = cfg.monitor;
        "CONTAINER_ENABLE_LOGSHIPPING" = cfg.logship;

        "MODE" = "BACKUP";

        #"BACKUP01_SNAPSHOT_NAME" = "persist";                                      # hosts/<hostname>/secrets/container-restic.env
        #"BACKUP01_SNAPSHOT_PATH" = "/rootfs/persist";                              # hosts/<hostname>/secrets/container-restic.env
        #"BACKUP01_SNAPSHOT_EXCLUDE" = ".snapshots";                                # hosts/<hostname>/secrets/container-restic.env
        #"BACKUP01_SNAPSHOT_BEGIN" = "+1";                                          # hosts/<hostname>/secrets/container-restic.env
        #"BACKUP01_SNAPSHOT_INTERVAL" = "60";                                       # hosts/<hostname>/secrets/container-restic.env
        #"BACKUP01_SNAPSHOT_BLACKOUT_BEGIN" = "0300";                               # hosts/<hostname>/secrets/container-restic.env
        #"BACKUP01_SNAPSHOT_BLACKOUT_END" = "0500";                                 # hosts/<hostname>/secrets/container-restic.env
        #"BACKUP01_REPOSITORY_PASS" = "repository_password";                        # hosts/<hostname>/secrets/container-restic.env
        #"BACKUP01_REPOSITORY_PATH" = "rest:https://host_env:host_env@host_env/";   # hosts/<hostname>/secrets/container-restic.env

        #"BACKUP02_SNAPSHOT_NAME" = "home";
        #"BACKUP02_SNAPSHOT_PATH" = "/rootfs/home";
        #"BACKUP02_SNAPSHOT_EXCLUDE" = ".snapshots,.vscode-server,.cache";
        #"BACKUP02_SNAPSHOT_BEGIN" = "+1";
        #"BACKUP02_SNAPSHOT_INTERVAL" = "60";
        #"BACKUP02_SNAPSHOT_BLACKOUT_BEGIN" = "0300";
        #"BACKUP02_SNAPSHOT_BLACKOUT_END" = "0500";
        #"BACKUP02_REPOSITORY_PASS" = "repository_password";
        #"BACKUP02_REPOSITORY_PATH" = "rest:https://host_env:host_env@host_env/";

        #"BACKUP03_SNAPSHOT_NAME" = "var_local";
        #"BACKUP03_SNAPSHOT_PATH" = "/rootfs/var/local/data";
        #"BACKUP03_SNAPSHOT_EXCLUDE" = ".snapshots,cache,data/cache,restic/cache,*.db-shm,*.db-wal,*.log.db";
        #"BACKUP03_SNAPSHOT_BEGIN" = "+1";
        #"BACKUP03_SNAPSHOT_INTERVAL" = "60";
        #"BACKUP03_SNAPSHOT_BLACKOUT_BEGIN" = "0300";
        #"BACKUP03_SNAPSHOT_BLACKOUT_END" = "0500";
        #"BACKUP03_REPOSITORY_PASS" = "repository_password";
        #"BACKUP03_REPOSITORY_PATH" = "rest:https://host_env:host_env@host_env/";

        #"BACKUP04_SNAPSHOT_NAME" = "w-persist";
        #"BACKUP04_SNAPSHOT_PATH" = "/rootfs/persist";
        #"BACKUP04_SNAPSHOT_EXCLUDE" = ".snapshots";
        #"BACKUP04_SNAPSHOT_BEGIN" = "0301";
        #"BACKUP04_SNAPSHOT_INTERVAL" = "1440";
        #"BACKUP04_SNAPSHOT_BLACKOUT_BEGIN" = "0500";
        #"BACKUP04_SNAPSHOT_BLACKOUT_END" = "0300";
        #"BACKUP04_REPOSITORY_PASS" = "repository_password";
        #"BACKUP04_REPOSITORY_PATH" = "rest:https://host_env:host_env@host_env/";

        #"BACKUP05_SNAPSHOT_NAME" = "w-home";
        #"BACKUP05_SNAPSHOT_PATH" = "/rootfs/home";
        #"BACKUP05_SNAPSHOT_EXCLUDE" = ".snapshots,.vscode-server,.cache";
        #"BACKUP05_SNAPSHOT_BEGIN" = "0302";
        #"BACKUP05_SNAPSHOT_INTERVAL" = "1440";
        #"BACKUP05_SNAPSHOT_BLACKOUT_BEGIN" = "0500";
        #"BACKUP05_SNAPSHOT_BLACKOUT_END" = "0300";
        #"BACKUP05_REPOSITORY_PASS" = "repository_password";
        #"BACKUP05_REPOSITORY_PATH" = "rest:https://host_env:host_env@host_env/";

        #"BACKUP06_SNAPSHOT_NAME" = "w-var_local";
        #"BACKUP06_SNAPSHOT_PATH" = "/rootfs/var/local/data";
        #"BACKUP06_SNAPSHOT_EXCLUDE" = ".snapshots,dbbackup/archive,backup/archive,cache,data/cache,restic/cache,*.db-shm,*.db-wal,*.log.db";
        #"BACKUP06_SNAPSHOT_BEGIN" = "0304";
        #"BACKUP06_SNAPSHOT_INTERVAL" = "1440";
        #"BACKUP06_SNAPSHOT_BLACKOUT_BEGIN" = "0500";
        #"BACKUP06_SNAPSHOT_BLACKOUT_END" = "0300";
        #"BACKUP06_REPOSITORY_PASS" = "repository_password";
        #"BACKUP06_REPOSITORY_PATH" = "rest:https://host_env:host_env@host_env/";
      };
      environmentFiles = [
        config.sops.secrets."host-container-${container_name}".path
      ];
      extraOptions = [
        #"--memory=256M" ## TODO: Map
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