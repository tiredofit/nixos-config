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
    boot.kernelParams = [
      "uvcvideo"
    ];

    services.pipewire = mkIf (config.host.hardware.sound.enable && config.host.hardware.sound.server == "pipewire") {
      wireplumber = {
        extraConfig = {
          "10-disable-camera" = {
              "wireplumber.profiles" = {
                main."monitor.libcamera" = "disabled";
              };
          };
        };
      };
    };
  };
}
