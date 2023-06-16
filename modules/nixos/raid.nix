{config, lib, pkgs, ...}:

let
  cfg_raid = config.hostoptions.raid;
in
  with lib;
{
  options = {
    hostoptions.raid = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables tools for RAID";
      };
    };
  };

  config = mkIf cfg_raid.enable {
    environment.systemPackages = with pkgs; [
      dmraid
      gptfdisk
    ];
  };
}
