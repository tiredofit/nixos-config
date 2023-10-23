{config, lib, pkgs, ...}:

let
  cfg = config.host.application.git;
in
  with lib;
{
  options = {
    host.application.git = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables git";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
      git-lfs
    ];
  };
}