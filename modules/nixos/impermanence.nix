{ config, pkgs, impermanence , ... } @ args:
{
  imports =
    [
      impermanence.nixosModules.impermanence
    ];

  boot.initrd = {
    systemd = {
      enable = true;
      services.rollback = {
        description = "Rollback BTRFS root subvolume to a pristine state";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          "systemd-cryptsetup@pool0_0.service"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
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
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true ;
    directories = [
      "/etc/nixos"                       # NixOS
      "/etc/NetworkManager"              # NetworkManager
      "/root"                            # Root
      "/var/lib/NetworkManager"          # NetworkManager
    ];
    files = [
      "/etc/machine-id"
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
