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

  fluentConfig = pkgs.writeText "fluent-bit.conf" ''
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
  };
}
