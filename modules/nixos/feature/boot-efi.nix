{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.boot-efi;
in
  with lib;
{
  options = {
    host.feature.boot-efi = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Enables booting via EFI";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = false;
        };
        grub = {
          enable = true;
          device = "nodev";
          efiSupport = true;
          enableCryptodisk = false;
          useOSProber = false;
          efiInstallAsRemovable = true;
        };
      };
    };
  };
}
