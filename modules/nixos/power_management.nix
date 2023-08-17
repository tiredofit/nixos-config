{config, lib, pkgs, ...}:

let
  cfg_powermanagement = config.hostoptions.powermanagement;
in
  with lib;
{
  options = {
    hostoptions.powermanagement = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Enables tools and automatic powermanagement";
      };
      disks-platter = mkOption {
        default = true;
        type = with types; bool;
        description = "Enables powermanagement spin down for platter hard drives";
      };
    };
  };

  config = mkIf cfg_powermanagement.enable {
    environment.systemPackages = with pkgs; [
      power-profiles-daemon # dbus power profiles
    ];

    powerManagement = {
      enable = true ;
      powerUpCommands = mkIf cfg_powermanagement.disks-platter '' # Shutdown after 9 minutes
        ${pkgs.bash}/bin/bash -c "set -x ; ${pkgs.hdparm}/bin/hdparm -S 9 -B 127 $(${pkgs.utillinux}/bin/lsblk -dnp -o name,rota | ${pkgs.gnugrep}/bin/grep '.*\\s1'| ${pkgs.coreutils}/bin/awk '{print $1}')"
      '';
    };

    services = {
      power-profiles-daemon.enable = true;
      thermald.enable = true ;
    };
  };
}
