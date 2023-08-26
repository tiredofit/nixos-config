{config, lib, pkgs, ...}:

let
  cfg = config.host.network.firewall.opensnitch;
in
  with lib;
{
  options = {
    host.network.firewall.opensnitch = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Opensnitch Application Firewall";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      opensnitch = {
        enable = true;
        rules = {
        };
      };
    };

    host.filesystem.impermanence.directories = lib.mkIf config.host.filesystem.impermanence.enable [
      "/var/lib/opensnitch"          # Opensnitch
    ];
  };
}
