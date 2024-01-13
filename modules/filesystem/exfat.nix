{config, lib, pkgs, ...}:

let
  cfg = config.host.filesystem.exfat;
in
  with lib;
{
  options = {
    host.filesystem.exfat = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables support for reading ExFAT (Microsoft) drives";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      supportedFilesystems = [
        "exfat"
      ];
    };

    environment.systemPackages =  with pkgs; [
      exfatprogs
    ];
  };
}
