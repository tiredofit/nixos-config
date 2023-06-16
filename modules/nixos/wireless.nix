{config, lib, pkgs, ...}:

let
  cfg_wireless = config.hostoptions.wireless;
in
  with lib;
{
  options = {
    hostoptions.wireless = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Enables tools for wireless";
      };
    };
  };

  config = mkIf cfg_wireless.enable {
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom="CA"
    '';
    hardware.wirelessRegulatoryDatabase = true;

    services.udev.packages = [ pkgs.crda ];
  };
}
