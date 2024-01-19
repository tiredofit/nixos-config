{config, lib, pkgs, ...}:

let
  cfg = config.host.hardware.yubikey;
in
  with lib;
{
  options = {
    host.hardware.yubikey = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Yubikey support";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      #yubikey-manager
      #yubikey-manager-qt
      yubikey-personalization
      yubikey-personalization-gui
      yubico-piv-tool
      yubioath-flutter
    ];

    hardware.gpgSmartcards.enable = true;

    services = {
      pcscd.enable = true;
      udev.packages = [pkgs.yubikey-personalization];
    };

    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };
}
