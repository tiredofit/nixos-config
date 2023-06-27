{ config, pkgs, impermanence , ... } @ args:
{
  imports =
    [
      impermanence.nixosModules.impermanence
    ];

  boot = {
    initrd.postDeviceCommands = pkgs.lib.mkBefore ''
      mkdir -p /mnt
      mount -o subvol=/ /dev/mapper/pool0_0 /mnt
      btrfs subvolume list -o /mnt/root | cut -f9 -d' ' |
      while read subvolume; do
          echo "Deleting /$subvolume subvolume"
          btrfs subvolume delete "/mnt/$subvolume"
      done &&
      echo "Deleting /root subvolume" &&
      btrfs subvolume delete /mnt/root
      echo "Restoring blank /root subvolume"
      btrfs subvolume snapshot /mnt/root-blank /mnt/root
      umount /mnt
    '';
  };

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/etc/nixos"                       # NixOS
      "/etc/NetworkManager"              # NetworkManager
      "/root"                            # Root
      "/var/lib/bluetooth"               # Bluetooth
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }        # Colord Profiles
      "/var/lib/docker"                  # Docker
      "/var/lib/NetworkManager"          # NetworkManager
    ];
    files = [
    ];
  };

  fileSystems."/persist".options = [ "subvol=persist" "compress=zstd" "noatime"  ];
  fileSystems."/persist".neededForBoot = true;

  security.sudo.extraConfig = ''
    Defaults lecture = never
  ''; # Gets annoying after being reset after reboot

  services.openssh = {
    hostKeys =
      [
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/persist/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
          bits = 4096;
        }
      ];
   };
}
