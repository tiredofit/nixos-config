{config, lib, pkgs, ...}:

let
  cfg = config.host.application.coreutils;
in
  with lib;
{
  options = {
    host.application.coreutils = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables coreutils";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      coreutils
    ];
  };
}