{config, lib, pkgs, ...}:

let
  cfg = config.host.network.vpn.wireguard;
in
  with lib;
{
  options = {
    host.network.vpn.wireguard = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Wireguard Tools";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
  };
}
