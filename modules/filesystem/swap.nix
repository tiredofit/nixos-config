 {config, lib, pkgs, ...}:

let
  cfg = config.host.filesystem.swap;
  swap_location =
    if cfg.type == "file"
    then cfg.file
    else "/dev/"+cfg.partition;
in
  with lib;
{
  options = {
    host.filesystem.swap = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Swap";
      };
      type = mkOption {
        default = null;
        type = types.enum ["file" "partition"];
        description = "Swap Type";
      };
      encrypt = mkOption {
        default = true;
        type = with types; bool;
        description = "Perform random encryption";
      };
      file = mkOption {
        default = "/swap/swapfile";
        type = with types; str;
        description = "Location of Swapfile";
      };
      partition = mkOption {
        default = null;
        type = with types; str;
        example = "sda2";
        description = "Partition to be used for swap";
      };
      size= mkOption {
        type = with types; int;
        default = 8192;
        description = "Size in Megabytes";
      };
    };
  };

  config = mkMerge [
    # Don't use BTRFS subvolume if RAID is involved.
    (mkIf ((cfg.enable) && (!config.host.hardware.raid.enable) && (cfg.type == "file")) {
      fileSystems = mkIf (config.host.filesystem.btrfs.enable) {
        "/swap".options = [ "subvol=swap" "nodatacow" "noatime" ];
      };

      swapDevices = [{
        device = swap_location;
        randomEncryption = {
          enable = cfg.encrypt;
          allowDiscards = "once";
        };
        size = cfg.size;
      }];
    })

    (mkIf ((cfg.enable) && (cfg.type == "partition")) {
      swapDevices = [{
        device = swap_location;
        randomEncryption.enable = false;
      }];
    })

  {
    systemd.services = mkIf ((cfg.type == "file") && (!config.host.hardware.raid.enable) && (cfg.enable)) {
      create-swapfile =  {
        serviceConfig.Type = "oneshot";
        wantedBy = [ "swap-swapfile.swap" ];
        script = ''
          swapfile="${cfg.file}"
          if [ -f "$swapfile" ]; then
              echo "Swap file $swapfile already exists, taking no action"
          else
              echo "Setting up swap file $swapfile"
              ${pkgs.coreutils}/bin/truncate -s 0 "$swapfile"
              ${pkgs.e2fsprogs}/bin/chattr +C "$swapfile"
              ${pkgs.btrfs-progs}/bin/btrfs property set "$swapfile" compression none
              ${pkgs.coreutils}/bin/dd if=/dev/zero of="$swapfile bs=1M count=${cfg.size} status=progress
              ${pkgs.coreutils}chmod 0600 ${swapfile}
              ${pkgs.util-linux}/bin/mkswap ${swapfile}
          fi
        '';
      };
    };
  }];
}
