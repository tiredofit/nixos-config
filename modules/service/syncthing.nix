{config, lib, pkgs, ...}:

let
  cfg = config.host.service.syncthing;
in
  with lib;
{
  options = {
    host.service.syncthing = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables Sycnthing";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      syncthing = {
        enable = true;
      };
    };

    host = {
      filesystem = {
        impermanence.directories =
          lib.mkIf config.host.filesystem.impermanence.enable [
            "/var/lib/syncthing" # Syncthing
          ];
      };
    };
  };
}
