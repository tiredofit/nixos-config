{ config, pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    power-profiles-daemon # dbus power profiles
 
  ];

  # TODO - MkIf Shuts down platter/rotational hard disks after 9 minutes
  powerManagement = {
    enable = true ;
    powerUpCommands = with pkgs;''
      ${bash}/bin/bash -c "set -x ; ${hdparm}/bin/hdparm -S 9 -B 127 $(${utillinux}/bin/lsblk -dnp -o name,rota | ${gnugrep}/bin/grep '.*\\s1'| ${coreutils}/bin/awk '{print $1}')"
    '';
  };

  services = {
    power-profiles-daemon.enable = true;
    thermald.enable = true ; 
  };
}
