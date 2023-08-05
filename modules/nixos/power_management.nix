{ pkgs, config, ...}:

{
  environment.systemPackages = with pkgs; [
    power-profiles-daemon # dbus power profiles
  ];

  services.power-profiles-daemon.enable = true;
  # TODO - MkIf Shuts down platter/rotational hard disks after 9 minutes
  powerManagement = {
    enable = true ;
    powerUpCommands = with pkgs;''
      ${bash}/bin/bash -c "${hdparm}/bin/hdparm -S 9 -B 127 $(${utillinux}/bin/lsblk -dnp -o name,rota |${gnugrep}/bin/grep \'.*\\s1\'|${coreutils}/bin/cut -d \' \' -f 1)"
    '';
  };
}
