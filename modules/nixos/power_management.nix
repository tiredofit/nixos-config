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
      hdparm                # Hard Drive management
      power-profiles-daemon # dbus power profiles
      smartmontools         # SMART montioring
    ];

    powerManagement = {
      enable = true ;
    };

    services = {
      power-profiles-daemon.enable = true;
      udev = {
        path = [ pkgs.hdparm ];
        extraRules = ''
          ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 108 -B 127 /dev/%k"
        '';
      };
      thermald.enable = true ;
    };
  };
}
