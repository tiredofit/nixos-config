{config, lib, pkgs, ...}:

let
  cfg_steam = config.host.feature.gaming.steam;
in
  with lib;
  eith pkgs;
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

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf config.host.feature.gaming.enable [
      steam-rom-manager
      steam-run
      steam-tui
    ];

    programs.steam = mkIf config.host.feature.gaming.enable {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}