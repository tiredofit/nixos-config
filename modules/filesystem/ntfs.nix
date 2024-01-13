{config, lib, pkgs, ...}:

let
  cfg = config.host.filesystem.ntfs;
in
  with lib;
{
  options = {
    host.filesystem.ntfs = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables support for reading NTFS drives";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      supportedFilesystems = [
        "ntfs"
      ];
    };
  };
}
