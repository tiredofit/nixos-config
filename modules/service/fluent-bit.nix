{ config, lib, pkgs, ... }:

let
  BoolOnOff = x:
    if x
    then "On"
    else "Off";

  cfg = config.host.service.fluentbit;

  customConfPath =
    if (config.host.service.fluentbit.custom.path != "null")
    then "@INCLUDE ${cfg.custom.path}/*.conf"
    else " ";
in
  with lib;
{
  options = {
    host.service.fluentbit = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables daemon for shipping logs and metrics";
      };
      custom.path = mkOption {
        type = with types; str;
        default = "null";
        description = "Custom path to load *.conf files (loose and non declarative)";
      };
      flush = mkOption {
        default = 1;
        type = with types; int;
        description = "Flush time in seconds";
      };
      grace = mkOption {
        default = 1;
        type = with types; int;
        description = "Wait time before exit in seconds";
      };
      httpserver.enable = mkOption {
        type = with types; bool;
        default = false;
        description = "Enable HTTP Server";
      };
      httpserver.listenIP = mkOption {
        type = with types; str;
        default = "0.0.0.0";
        description = "IP Address to listen for remote connections for HTTP server";
      };
      httpserver.listenPort = mkOption {
        type = with types; port;
        default = 2020;
        description = "Port to listen for HTTP server";
      };
      input.docker.enable = mkOption {
        type = with types; bool;
        default = false;
        description = "Enable Docker log collection";
      };
      input.kernel.enable = mkOption {
        type = with types; bool;
        default = false;
        description = "Enable Kernel log collection";
      };
      input.systemd.enable = mkOption {
        type = with types; bool;
        default = false;
        description = "Enable SystemD log collection";
      };
      log.file = mkOption {
        type = with types; str;
        default = "fluentbit.log";
        description = "Log Path";
      };
      log.level = mkOption {
        type = with types; enum [ "info" "warn" "error" "debug" "trace" ];
        default = "info";
        description = "Log Level";
      };
      log.path = mkOption {
        type = with types; str;
        default = "/var/log/fluentbit";
        description = "Log Path";
      };
      output.forward.enable = mkOption {
        type = with types; bool;
        default = false;
        description = "Enable forwarding";
      };
      output.forward.host = mkOption {
        type = with types; str;
        default = "null";
        description = "Host of remote forwarder";
      };
      output.forward.port = mkOption {
        type = with types; port;
        default = 24224;
        description = "Port of remote forwarder";
      };
      output.forward.tls.enable = mkOption {
        type = with types; bool;
        default = false;
        description = "Use TLS to connect to remote forwarder";
      };
      output.forward.tls.verify = mkOption {
        type = with types; bool;
        default = false;
        description = "Verify TLS when connecting to remote forwarder";
      };
      output.loki.enable = mkOption {
        type = with types; bool;
        default = false;
        description = "Output to a Loki server";
      };
      output.loki.compress_gzip = mkOption {
        type = with types; bool;
        default = true;
        description = "Compress output with gzip before sending to loki host";
      };
      output.loki.host = mkOption {
        type = with types; str;
        default = "null";
        description = "Host or IP Address of Loki host";
      };
      output.loki.port = mkOption {
        type = with types; port;
        default = 3100;
        description = "Port of Loki host";
      };
      output.loki.tls.enable = mkOption {
        type = with types; bool;
        default = false;
        description = "Use TLS to access Loki host";
      };
      output.loki.tls.verify = mkOption {
        type = with types; bool;
        default = false;
        description = "Verify TLS";
      };
      output.loki.tenant_id = mkOption {
        type = with types; str;
        default = "null";
        description = "Tenant ID to advertise to Loki Host";
      };
      storage.backlog_memory_limit = mkOption {
        type = with types; str;
        default = "5M";
        description = "Maximum about of memory to use for backlogged/unsent records";
      };
      storage.checksum = mkOption {
        type = with types; bool;
        default = false;
        description = "Create CRC32 checksum for filesystem RW functions";
      };
      storage.metrics = mkOption {
        type = with types; bool;
        default = true;
        description = "Export storage metrics";
      };
      storage.path = mkOption {
        type = with types; str;
        default = "/tmp/fluentbit/storage";
        description = "Absolute file system path to store filesystem data buffers";
      };
      storage.sync = mkOption {
        type = with types; enum [ "normal" "full" ];
        default = "normal";
        description = "Synchronization mode to store data in filesystem";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = mkIf (! config.host.feature.secrets.enable) [
      {
        assertion = (cfg.output.loki.enable);
        message = "You need to enable secrets before using the Loki Output plugin due to it passing credentials";
      }
    ];

    environment.systemPackages = with pkgs; [
      fluent-bit
    ];

    services = {
      logrotate.settings."${cfg.log.path}/${cfg.log.file}" = { };
    };

    systemd.services.fluent-bit = {
      enable = true;
      description = "Log processor and forwarder";
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.fluent-bit}/bin/fluent-bit --config=/etc/fluent-bit/fluent-bit.conf";
        LogsDirectory = "fluentbit";
        LogsDirectoryMode = "0750";
      };
    };

    environment.etc = {
      "fluent-bit/fluent-bit.conf" = {
         text = ''
           @INCLUDE conf.d/*.conf
           ${customConfPath}

           [SERVICE]
            flush        ${toString cfg.flush}
            grace        ${toString cfg.grace}
            daemon       Off
            log_level    ${cfg.log.level}
            log_file     ${cfg.log.path}/${cfg.log.file}
            parsers_file parsers.conf
            plugins_file plugins.conf
            http_server  ${BoolOnOff cfg.httpserver.enable}
            http_listen  ${cfg.httpserver.listenIP}
            http_port    ${toString cfg.httpserver.listenPort}
            storage.metrics ${BoolOnOff cfg.storage.metrics}
            storage.path ${toString cfg.storage.path}
            storage.sync ${cfg.storage.sync}
            storage.checksum ${BoolOnOff cfg.storage.checksum}
            storage.backlog.mem_limit ${cfg.storage.backlog_memory_limit}
         '';
         mode = "0440";
      };

      "fluent-bit/conf.d/do_not_delete.conf" = {
         text = ''
           # Don't delete this configuration file otherwise execution of fluent-bit will fail. It will not affect operation of your system or impact resources
           [INPUT]
               Name   dummy
               Tag    ignore

           [FILTER]
               Name grep
               Match ignore
               regex ignore ignore

           [OUTPUT]
               Name   NULL
               Match  ignore
         '';
         mode = "0440";
      };

      ## TODO This could be better modularized for the docker socket
      "fluent-bit/conf.d/in_docker.conf" = mkIf ((cfg.input.docker.enable) && (config.host.feature.virtualization.docker.enable)) {
         text = ''
                  [INPUT]
                      Name   docker_events
                      Unix_Path /var/run/docker.sock
                      Tag docker-events

                 [FILTER]
                      Name parser
                      Match docker-events
                      Key_Name data
                      Parser docker

                 [FILTER]
                      Name record_modifier
                      Match docker-events
                      Record hostname ${config.networking.hostName}
                      Record container_name ${config.networking.hostName}
                      Record product docker-events
                '';
         mode = "0440";
      };

      "fluent-bit/conf.d/in_kernel.conf" = mkIf (cfg.input.kernel.enable) {
         text = ''
                  [INPUT]
                      Name   kmsg
                      Tag    kernel

                  [FILTER]
                      Name record_modifier
                      Match kernel
                      Record hostname ${config.networking.hostName}
                      Record container_name ${config.networking.hostName}
                      Record product kernel
                '';
         mode = "0440";
      };

      "fluent-bit/conf.d/in_systemd.conf" = mkIf (cfg.input.systemd.enable) {
         text = ''
                  [INPUT]
                      Name            systemd
                      Tag             host.*
                      Strip_Underscores On
                      Read_From_Tail On

                  [FILTER]
                      Name record_modifier
                      Match host.*
                      Record hostname ${config.networking.HostName}
                      Record container_name ${config.networking.HostName}
                      Record product systemd
         '';
         mode = "0440";
      };

      "fluent-bit/conf.d/out_forward.conf" = mkIf (cfg.output.forward.enable) {
         text = ''
                [OUTPUT]
                     Name          forward
                     Match         *
                     Host          ${cfg.output.forward.host}
                     Port          ${toString cfg.output.forward.port}
                     Self_Hostname ${config.networking.hostName}
                     tls           ${BoolOnOff cfg.output.forward.tls.enable}
                     tls.verify    ${BoolOnOff cfg.output.forward.tls.verify}
         '';
         mode = "0440";
      };

      "fluent-bit/conf.d/out_loki.conf" = mkIf (cfg.output.loki.enable) {
         text = ''
           [OUTPUT]
               name                   loki
               match                  *
               host                   ${cfg.output.loki.host}
               port                   ${toString cfg.output.loki.port}
               tls                    ${BoolOnOff cfg.output.loki.tls.enable}
               tls.verify             ${BoolOnOff cfg.output.loki.tls.verify}
               compress_gzip          ${BoolOnOff cfg.output.loki.compress_gzip}
               labels                 logshipper=${config.networking.hostName}
               Label_keys             $hostname,$container_name,$product
               http_user              ${config.sops.fluentbit.output.loki.http_user}
               http_passwd            ${config.sops.fluentbit.output.loki.http_pass}
         '';
         mode = "0440";
      };
    };

    ### We switch to SOPS declarations here because we have credentials that need to be secrets
    sops = {
      templates = {
        fluent_bit_output_loki = mkIf (cfg.output.loki.enable) {
          name = "fluent-bit/conf.d/out_loki.conf";
          path = "/etc/fluent-bit/conf.d/loki.conf";
          content = ''
            [OUTPUT]
              name                   loki
              match                  *
              host                   ${cfg.output.loki.host}
              port                   ${toString cfg.output.loki.port}
              tls                    ${BoolOnOff cfg.output.loki.tls.enable}
              tls.verify             ${BoolOnOff cfg.output.loki.tls.verify}
              labels                 logshipper=${config.networking.hostName}
              Label_keys             $hostname,$container_name,$product
              http_user              ${config.sops.fluentbit.output.loki.http_user}
              http_passwd            ${config.sops.fluentbit.output.loki.http_pass}
          '';
        };
      };
    };
  };
}
