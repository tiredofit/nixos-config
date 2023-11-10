{config, lib, pkgs, ...}:

let
  cfg = config.host.service.zabbix_agent;
in
  with lib;
{
  options = {
    host.service.zabbix_agent = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables metrics reporting";
      };
      controlSocket = mkOption {
        type = with types; str;
        default = "/run/zabbix_agent/zabbix.sock";
        description = "Path to Socket";
      };
      listenIP = mkOption {
        type = with types; str;
        default = "127.0.0.1";
        description = "Listening IP Address to accept connections from servers";
      };
      listenPort = mkOption {
        type = with types; port;
        default = 10050;
        description = "Listening Port to listen on to accept connections from servers";
      };
      server = mkOption {
        type = with types; str;
        default = "0.0.0.0/0";
        description = "IP Address to accept connections from servers";
      };
      serverActive = mkOption {
        type = with types; str;
        default = "null";
        description = "Server to send Active checks";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      zabbixAgent = {
        enable = true;
        listen = {
          ip = mkDefault cfg.listenIP ;
          port = mkDefault cfg.listenPort;
        };
        openFirewall = mkDefault true;
        package = mkDefault pkgs.zabbix.agent2;
        server = mkDefault cfg.server;
        settings = {
          BufferSend = mkDefault 5;
          BufferSize = mkDefault 100;
          ControlSocket = cfg.controlSocket;
          DebugLevel = mkDefault 2;
          Hostname = mkDefault config.networking.fqdn ;
          LogFile = mkDefault "/var/log/zabbix/zabbix_agentd.log";
          LogFileSize = mkDefault 0;
          LogType = mkForce "file";
          RefreshActiveChecks = mkDefault 120;
          Server = mkDefault cfg.server;
          ServerActive = mkDefault cfg.serverActive;
        };
      };
      logrotate.settings."/var/log/zabbix/zabbix_agentd.log" = {
      };
    };

    systemd.services.zabbix-agent = {
      serviceConfig = {
        LogsDirectory = "zabbix";
        LogsDirectoryMode = "0750";
        RuntimeDirectory = "zabbix_agent";
        RuntimeDirectoryMode = "0750";
      };
    };
  };
}
