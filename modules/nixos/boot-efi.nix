{config, lib, pkgs, ...}:

let
  cfg_boot-efi = config.hostoptions.boot-efi;
in
  with lib;
{
  options = {
    hostoptions.boot-efi = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Enables booting via EFI";
      };
    };
  };

  config = mkIf cfg_boot-efi.enable {
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
