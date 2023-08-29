{ config, inputs, lib, modulesPath, pkgs, ...}:
let
  role = config.host.role;
in
  with lib;
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = mkIf (role == "vm") {
    documentation = {                                 # This makes some nix commands not display --help
      enable = mkDefault false;
      info.enable = mkDefault false;
      man.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };

    host = {
      feature = {
        boot = {
          efi.enable = mkDefault true;
          graphical.enable = mkDefault false;
        };
        powermanagement = {
          enable = mkDefault true;
        };
      };
      hardware = {
        bluetooth.enable = mkDefault false;
        graphics = {
          enable = mkDefault false;                    # Maybe if we were doing openCL
        };
        printing.enable = mkDefault false;
        sound.enable = mkDefault true;
        webcam.enable = mkDefault false;
        wireless.enable = mkDefault false;
        yubikey.enable = mkDefault false;
      };
    };

    networking = {
      networkmanager= {
        enable = mkDefault true;
      };
    };

    services.qemuGuest.enable = mkDefault true;        # Make the assumption we're using QEMU

    systemd = {
      enableEmergencyMode = mkDefault false;           # Allow system to continue booting in headless mode.
      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };
  };
}
