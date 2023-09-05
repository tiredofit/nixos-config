{ config, lib, pkgs, ... }:

let
  BoolOnOff = x:
    if x
    then "On"
    else "Off";

  cfg = config.host.service.fluentbit;

  customConfPath =
    if (config.host.service.fluent-bit.custom.path != null)
    then "@INCLUDE ${config.host.custom.path}/*.conf"
    else " ";

  fluentConfig = pkgs.writeText "/etc/fluent-bit/fluent-bit.conf" ''
    @INCLUDE conf.d/*.conf
    ${customConfPath}

   [SERVICE]
    flush        ${cfg.flush}
    grace        ${cfg.grace}
    daemon       Off
    log_level    ${cfg.log.level}
    log_file     ${cfg.log.path}/${cfg.log.file}
    parsers_file parsers.conf
    plugins_file plugins.conf
    http_server  ${BoolOnOff cfg.httpserver.enable}
    http_listen  ${cfg.httpserver.listenIP}
    http_port    ${cfg.httpserver.listenPort}
    storage.metrics ${BoolOnOff cfg.storage.metrics}
    storage.path ${cfg.storage.path}
    storage.sync ${cfg.storage.sync}
    storage.checksum ${BoolOnOff cfg.storage.checksum}
    storage.backlog.mem_limit ${cfg.storage.backlog_memory_limit}
  '';
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
      ## TODO Fix this path
      custom.path = mkOption {
        type = with types; str;
        default = null;
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
        default = "false";
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
        default = "false";
        description = "Output to a FluentD/Fluent-bit forwarder";
      };
      output.forward.host = mkOption {
        type = with types; str;
        default = "null";
        description = "Host or IP Address of FluentD host";
      };
      output.forward.port = mkOption {
        type = with types; port;
        default = 24224;
        description = "Port of remote forwarder";
      };
      output.forward.tls.enable = mkOption {
        type = with types; bool;
        default = "false";
        description = "Use TLS to connect to remote forwarder";
      };
      output.forward.tls.verify = mkOption {
        type = with types; bool;
        default = "false";
        description = "Verify TLS when connecting to remote forwarder";
      };
      output.loki.enable = mkOption {
        type = with types; bool;
        default = "false";
        description = "Output to a Loki server";
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
        default = "false";
        description = "Use TLS to access Loki host";
      };
      output.loki.tls.verify = mkOption {
        type = with types; bool;
        default = "false";
        description = "Verify TLS";
      };
      output.loki.user = mkOption {
        type = with types; str;
        default = "null";
        description = "Username to access remote Loki Host";
      };
      output.loki.pass = mkOption {
        type = with types; str;
        default = "null";
        description = "Password to access remote Loki Host";  ## TODO TEST TO SEE IF WE CAN USE A SECRET
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
      storage.metrics = {
        type = with types; bool;
        default = true;
        description = "Export storage metrics";
      };
      storage.path = {
        type = with types; str;
        default = /tmp/fluentbit/storage;
        description = "Absolute file system path to store filesystem data buffers";
      };
      storage.sync = mkOption {
        type = with types; enum [ "normal" "full" ];
        default = "normal";
        description = "Synchronization mode to store data in filesystem";
      };
    };
  };

  ## TODO Add inputs, outputs, forwarders
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fluent-bit
    ];

    services = {
      logrotate.settings."${cfg.log.path}/${cfg.log.file}" = { };
    };

    systemd.services.fluent-bit = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Log processor and forwarder";
      serviceConfig = {
        ExecStart = "${pkgs.fluent-bit}/bin/fluent-bit --config=${fluentConfig}";
        serviceConfig = {
          LogsDirectory = "fluentbit";
          LogsDirectoryMode = "0750";
        };
      };
    };

    environment.etc = {
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

      "fluent-bit/conf.d/out_forward.conf" = (mkIf cfg.output.forward.enable) {
         text = ''
                [OUTPUT]
                     Name          forward
                     Match         *
                     Host          ${cfg.output.forward.host}
                     Port          ${cfg.output.forward.port}
                     Self_Hostname ${config.networking.hostName}
                     tls           ${BoolOnOff cfg.output.forward.tls.enable}
                     tls.verify    ${BoolOnOff cfg.output.forward.tls.verify}

         '';
         mode = "0440";
      };

      "fluent-bit/conf.d/out_loki.conf" = (mkIf cfg.output.loki.enable) {
         text = ''
                [OUTPUT]
                    name                   loki
                    match                  *
                    host                   ${cfg.output.loki.tls.host}
                    port                   ${cfg.output.loki.port}
                    tls                    ${cfg.output.loki.tls.enable}
                    tls.verify             ${cfg.output.loki.tls.verify}
                    labels                 logshipper=${config.networking.hostName}
                    Label_keys             $hostname,$container_name,$product
                    http_user              ${cfg.output.loki.user}
                    http_passwd            ${cfg.output.loki.pass}
                '';
         mode = "0440";
      };
    };
  };
}
