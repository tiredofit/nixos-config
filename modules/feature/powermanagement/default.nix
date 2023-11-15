{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.powermanagement;
  thermald =
    if (config.host.hardware.cpu == "intel")
    then true
    else false;
in
  with lib;
{
  imports = [
    ./tlp.nix
  ];
  options = {
    host.feature.powermanagement = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Enables tools and automatic powermanagement";
      };
      disks-platter = mkOption {
        default = true;
        type = with types; bool;
        description = "Enables spin down for platter hard drives";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hdparm                # Hard Drive management
      power-profiles-daemon # dbus power profiles
      smartmontools         # SMART montioring
    ];

    powerManagement = {
      enable = true ;
    };

    services = {
      power-profiles-daemon.enable = mkDefault true;
      udev = {
        path = [ pkgs.hdparm ];
        extraRules = ''
          ACTION=="add|change", KERNEL=="sd[a-z]", ATTRS{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 108 -B 127 /dev/%k"
        '';
      };
      thermald.enable = mkDefault thermald;
    };
  };
}
