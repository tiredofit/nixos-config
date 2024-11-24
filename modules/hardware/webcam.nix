{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.webcam;
  logitech_c920_microphone = pkgs.writeTextFile {
    destination = "/etc/udev/rules.d/99-disable-logitech_c920_microphone.rules";
    name        = "disable-logitch-c920-microphone";

    text = ''
      # Prevent Logitech HD Pro Webcam C920 microphone from being activated.
      ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="08e5", ATTR{bInterfaceClass}=="01", ATTR{authorized}="0"
    '';
  };
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
      logitech_c920_microphone = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Logitech C920 Microphone support";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.kernelParams = [
      "uvcvideo"
    ];

    services = {
      pipewire = mkIf (config.host.hardware.sound.enable && config.host.hardware.sound.server == "pipewire") {
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
      udev = mkIf (! cfg.logitech_c920_microphone ) {
        packages = [
          logitech_c920_microphone
        ];
      };
    };
  };
}
