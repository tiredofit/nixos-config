{ config, pkgs, impermanence, ... } @ args:
let
  impermanence-fsdiff = pkgs.writeShellScriptBin "impermanence-fsdiff" ''
_mount_drive=''${1:-"$(mount | grep '.* on / type btrfs' | awk '{ print $1}')"}
_tmp_root=$(mktemp -d)
mkdir -p "$_tmp_root"
sudo mount -o subvol=/ "$_mount_drive" "$_tmp_root" > /dev/null 2>&1

set -euo pipefail

OLD_TRANSID=$(sudo btrfs subvolume find-new $_tmp_root/root-blank 9999999)
OLD_TRANSID=''${OLD_TRANSID#transid marker was }

sudo btrfs subvolume find-new "$_tmp_root/root" "$OLD_TRANSID" | sed '$d' | cut -f17- -d' ' | sort | uniq |
while read path; do
    path="/$path"
    if [ -L "$path" ]; then
        : # The path is a symbolic link, so is probably handled by NixOS already
    elif [ -d "$path" ]; then
        : # The path is a directory, ignore
    else
        echo "$path"
    fi
done
sudo umount "$_tmp_root"
rm -rf "$_tmp_root"

  '';
in
{
  imports =
    [
      impermanence.nixosModules.impermanence
    ];

  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt
    mount -o subvol=/ /dev/disk/by-partlabel/pool0_0 /mnt
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
