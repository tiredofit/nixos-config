{config, lib, pkgs, ...}:

let
  cfg = config.host.network.firewall.fail2ban;
in
  with lib;
{
  options = {
    host.network.firewall.fail2ban = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable monitoring of services to automatically block bad actors";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      fail2ban = {
        enable = true;
        bantime = mkDefault "10m";
        bantime-increment = {
          enable = mkDefault true;
          factor = mkDefault "1";
          maxtime = mkDefault "48h";
          multipliers = mkDefault "1 2 4 8 16 32 64";
          rndtime = mkDefault "8m";
        };
        daemonSettings = {
          Definition = {
            loglevel = mkDefault "INFO";
            logtarget = "/var/log/fail2ban/fail2ban.log";
            socket = "/run/fail2ban/fail2ban.sock";
            pidfile = "/run/fail2ban/fail2ban.pid";
            dbfile = "/var/lib/fail2ban/fail2ban.sqlite3";
            dbpurageage = mkDefault "1d";
          };
        };
        ignoreIP = [
          "127.0.0.1/8"
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/24"
        ];
        maxretry = mkDefault 5;
      };

      logrotate.settings."/var/log/fail2ban/fail2ban.log" = {
      };
    };

    host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
      "/var/lib/fail2ban"                # Fail2ban Database
    ];
  };
}