{config, lib, pkgs, ...}:

let
  cfg = config.host.application.nano;
in
  with lib;
{
  options = {
    host.application.nano = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables nano lightweight text editor";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nano
    ];
  };
}