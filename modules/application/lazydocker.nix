{config, lib, pkgs, ...}:

let
  cfg = config.host.application.lazydocker;
in
  with lib;
{
  options = {
    host.application.lazydocker = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Docker Interface";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lazydocker
    ];
  };
}
