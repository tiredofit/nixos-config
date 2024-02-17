{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.wireless;
in
  with lib;
{
  options = {
    host.hardware.wireless = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables tools for wireless";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="CA"
    '';

    environment.systemPackages = with pkgs; [
      iw
    ];

    hardware.wirelessRegulatoryDatabase = true;
  };
}
