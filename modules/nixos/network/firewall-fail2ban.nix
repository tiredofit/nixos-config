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
      };
    };

    host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
      "/var/lib/fail2ban"                # Fail2ban Database
    ];
  };
}