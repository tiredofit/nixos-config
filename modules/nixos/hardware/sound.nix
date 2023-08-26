{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.sound;
in
  with lib;
{
  options = {
    host.hardware.sound = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Sound";
      };
      server = mkOption {
        type = types.str;
        default = "pulseaudio";
        description = "Which sound server (pulseaudio/pipewire)";
      };
    };
  };

  config = {
    sound = lib.mkMerge [
      (lib.mkIf (cfg.enable && cfg.server == "pulseaudio") {
        enable = true;
      })

      (lib.mkIf (cfg.enable && cfg.server == "pipewire") {
        enable = false;
      })

     (lib.mkIf (! cfg.enable ) {
        enable = false;
      })
     ];

    hardware.pulseaudio = mkIf (cfg.enable && cfg.server == "pulseaudio") {
      enable = true;
    };

    services.pipewire = mkIf (cfg.enable && cfg.server == "pipewire") {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    security.rtkit = mkIf (cfg.enable && cfg.server == "pipewire") {
      enable = true;
    };
  };
}
