{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.s3ql;
in
  with lib;
{
  options = {
    host.feature.s3ql = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable tools for accessing a filesystem via a S3 bucket";
      };
    };
  };

  ## TODO - Create additional options and SystemD service
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      s3ql
    ];
  };
}
