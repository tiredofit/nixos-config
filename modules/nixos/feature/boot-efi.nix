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
        type = types.enum [ "grub" ];
        description = "Enables booting via Grub";
        ## TODO Consider creating top level boot.nix feature and integrating systemd-boot or none (pi)
      };
    };
  };

  config = mkIf cfg.efi.enable {
    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = false;
        };
        grub = mkIf (cfg.loader == "grub") {
          enable = mkDefault true;
          device = "nodev";
          efiSupport = cfg.efi.enable;
          enableCryptodisk = mkDefault false;
          useOSProber = mkDefault false;
          efiInstallAsRemovable = true;
          #theme = null;
          #backgroundColor = null;
          #splashImage = null
        };
      };
    };
  };
}
