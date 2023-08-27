{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.webcam;
in
  with lib;
{
  options = {
    host.hardware.webcam = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Webcam support";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.kernelParams = ["uvcvideo"];
  };
}
