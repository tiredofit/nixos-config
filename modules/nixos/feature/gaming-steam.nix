{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.gaming.steam;
in
  with lib;
  with pkgs;
{
  options = {
    host.feature.gaming.steam = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Steam gaming support";
      };
    };
  };

  config = lib.mkIf (cfg.enable && config.host.feature.gaming.enable) {
    environment.systemPackages = [
      steam-rom-manager
      steam-run
      steam-tui
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}