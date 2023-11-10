{config, lib, pkgs, ...}:

let
  cfg = config.host.service.monit;
in
  with lib;
{
  options = {
    host.service.monit = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables monit service";
      };
      settings = {
        checkInterval = mkOption {
          default = "30";
          type = with types; str;
          description = "Check services at however many second intervals";
        };
        mail = {
          from = mkOption {
            type = with types; str;
            default = "${config.networking.hostName}@${config.networking.domain}";
            description = "Address to send notification mails from";
          };
          to = mkOption {
            type = with types; str;
            default = "null@example.com";
            description = "Address to send notification mails to";
          };
        };
        smtp = {
          host = mkOption {
            type = with types; str;
            default = "127.0.0.1";
            description = "Server to send Active checks";
          };
          port = mkOption {
            type = with types; str;
            default = "25";
            description = "Port of SMTP server";
          };
          user = mkOption {
            default = "null";
            type = with types; nullOr str;
            description = "Username to use when connecting to smtp.host";
          };
          password = mkOption { ## TODO this is insecure
            default = "null";
            type = with types; nullOr str;
            description = "Username to use when connecting to smtp.host";
          };
        };
      };
      usage = {
        cpu = {
          enable = mkOption {
            default = true;
            type = with types; bool;
            description = "Enables CPU usage monitoring";
          };
          cycles = mkOption {
            default = "10";
            type = with types; str;
            description = "How many cycleIntervals before alerting";
          };
          limit = mkOption {
            default = "95%";
            type = with types; str;
            description = "Limit for usage monitoring";
          };
        };
        filesystem = { ## TODO Make this into sets
          enable = mkOption {
            default = true;
            type = with types; bool;
            description = "Enables filesystem usage monitoring";
          };
          limit = mkOption {
            default = "90%";
            type = with types; str;
            description = "Limit for usage monitoring";
          };
          name = mkOption {
            default = "rootfs";
            type = with types; str;
            description = "Friendly name of path";
          };
          path = mkOption {
            default = "/";
            type = with types; str;
            description = "Path to monitor";
          };
        };
        load = {
          enable = mkOption {
            default = true;
            type = with types; bool;
            description = "Enables load monitoring";
          };
          "1min" = {
            cycles = mkOption {
              default = "4";
              type = with types; str;
              description = "How many cycleIntervals before alerting";
            };
            limit = mkOption {
              default = "2";
              type = with types; str;
              description = "Limit for usage monitoring";
            };
          };
          "5min" = {
            cycles = mkOption {
              default = "10";
              type = with types; str;
              description = "How many cycleIntervals before alerting";
            };
            limit = mkOption {
              default = "1.5";
              type = with types; str;
              description = "Limit for usage monitoring";
            };
          };
          "15min" = {
            cycles = mkOption {
              default = "15";
              type = with types; str;
              description = "How many cycleIntervals before alerting";
            };
            limit = mkOption {
              default = "15";
              type = with types; str;
              description = "Limit for usage monitoring";
            };
            times = mkOption {
              default = "5";
              type = with types; str;
              description = "Amount of times this can occur during cycles limit";
            };
          };
        };
        memory = {
          enable = mkOption {
            default = true;
            type = with types; bool;
            description = "Enables memory usage";
          };
          cycles = mkOption {
            default = "4";
            type = with types; str;
            description = "How many cycleIntervals before alerting";
          };
          limit = mkOption {
            default = "75%";
            type = with types; str;
            description = "Limit for usage monitoring";
          };
        };
        swap = {
          enable = mkOption {
            default = true;
            type = with types; bool;
            description = "Enables swap monitoring";
          };
          cycles = mkOption {
            default = "4";
            type = with types; str;
            description = "How many cycleIntervals before alerting";
          };
          limit = mkOption {
            default = "75%";
            type = with types; str;
            description = "Limit for usage monitoring";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      monit = {
        enable = true;
        config =
          let
            monit_smtp_user = if ! (cfg.settings.smtp.user == "null")
              then "USERNAME ${cfg.settings.smtp.user}"
              else "";

            monit_smtp_pass = if ! (cfg.settings.smtp.password == "null")
              then "PASSWORD ${cfg.settings.smtp.password}"
              else "";

            monit_cpu = if cfg.usage.cpu.enable
              then "if cpu usage > ${cfg.usage.cpu.limit} for ${cfg.usage.cpu.cycles} cycles then alert"
              else "";

            monit_disk = if cfg.usage.filesystem.enable
              then ''
              check filesystem ${cfg.usage.filesystem.name} with path ${cfg.usage.filesystem.path}
                if space usage > ${cfg.usage.filesystem.limit} then alert
              ''
              else "";

            monit_load = if cfg.usage.load.enable
              then ''
                  if loadavg (1min) per core > ${cfg.usage.load."1min".limit} for ${cfg.usage.load."1min".cycles} cycles then alert
                      if loadavg (5min) per core > ${cfg.usage.load."5min".limit} for ${cfg.usage.load."5min".cycles} cycles then alert
                      if loadavg (15min) > ${cfg.usage.load."15min".limit} for ${cfg.usage.load."15min".times} times within ${cfg.usage.load."15min".cycles} cycles then alert
              ''
              else "";

            monit_memory = if cfg.usage.memory.enable
              then "if memory usage > ${cfg.usage.memory.limit} for ${cfg.usage.memory.cycles} cycles then alert"
              else "";

            monit_swap = if cfg.usage.swap.enable
              then "if swap usage > ${cfg.usage.swap.limit} for ${cfg.usage.swap.cycles} cycles then alert"
              else "";

          in ''
          set daemon ${cfg.settings.checkInterval}
          set log syslog

          set pidfile /var/run/monit.pid
          set idfile /var/lib/monit/.monit.id
          set statefile /var/tmp/.monit.state
          set mailserver ${cfg.settings.smtp.host} port ${cfg.settings.smtp.port} ${monit_smtp_user} ${monit_smtp_pass} using ${config.networking.hostName}.${config.networking.domain}

          set eventqueue
              basedir /var/lib/monit
              slots 100

          set mail-format {
             from: ${cfg.settings.mail.from}
             subject: monit alert --  $EVENT $SERVICE
             message: $EVENT Service $SERVICE
                           Date:        $DATE
                           Action:      $ACTION
                           Host:        $HOST
                           Description: $DESCRIPTION
           }

          set alert ${cfg.settings.mail.to}

          check system $HOST
              ${monit_cpu}
              ${monit_load}
              ${monit_memory}
              ${monit_swap}

          ${monit_disk}
        '';
      };
    };

    host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
      "/var/lib/monit"
    ];
  };
}