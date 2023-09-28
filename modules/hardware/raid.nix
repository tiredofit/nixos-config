{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.raid;
in
  with lib;
{
  options = {
    host.hardware.raid = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables tools for RAID";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      dmraid
      gptfdisk
    ];

    boot = mkIf config.host.filesystem.encryption.enable {
      initrd = {
        luks.devices = {
          "pool0_1" = {
             allowDiscards = true;
             bypassWorkqueues = true;
          };
        };
      };
    };
  };
}
