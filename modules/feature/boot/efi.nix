{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.boot;
in
  with lib;
{
  options = {
    host.feature.boot = {
      efi = {
        enable = mkOption {
          default = true;
          type = with types; bool;
          description = "Enables booting via EFI";
        };
      };
      loader = mkOption {
        default = "grub";
        type = types.enum [ "grub" "systemd" ];
        description = "Enables booting via Grub";
        ## TODO Consider creating top level boot.nix feature and integrating systemd-boot or none (pi)
      };
    };
  };

  config = mkIf cfg.efi.enable {
    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = mkDefault false;
        };
        grub = mkIf (cfg.loader == "grub") {
          enable = mkDefault true;
          device = "nodev";
          efiSupport = cfg.efi.enable;
          enableCryptodisk = mkDefault false;
          useOSProber = mkDefault false;
          efiInstallAsRemovable = mkDefault true;
          #theme = mkDefault null;
          #backgroundColor = mkDefault null;
          #splashImage = mkDault null
        };
        systemd-boot = mkIf (cfg.loader == "systemd") {
          enable = mkDefault true;
        };
      };
    };
  };
}
