 {config, lib, pkgs, ...}:

let
  cfg = config.host.filesystem.swap_file;
in
  with lib;
{
  options = {
    host.filesystem.swap_file = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Utilize a Swap File";
      };
      encrypt = mkOption {
        default = true;
        type = with types; bool;
        description = "Perform random encryption";
      };
      path = mkOption {
        type = types.str;
        default = "/swap/swapfile";
        description = "Size in Gigabytes";
      };
      size= mkOption {
        type = types.int;
        default = "8";
        description = "Size in Gigabytes";
      };
    };
  };

  config = mkIf cfg.enable {
    # Don't use BTRFS subvolume if RAID is involved.
    fileSystems = lib.mkIf (config.host.filesystem.btrfs.enable && !config.host.hardware.raid.enable) {
      "/swap".options = [ "subvol=swap" "compress=zstd" "noatime" ];
    };

    systemd.services = {
      create-swapfile = {
        serviceConfig.Type = "oneshot";
        wantedBy = [ "swap-swapfile.swap" ];
        script = ''
          swapfile="${config.host.filesystem.swap_file.path}"
          if [ -f "$swapfile" ]; then
              echo "Swap file $swapfile already exists, taking no action"
          else
              echo "Setting up swap file $swapfile"
              ${pkgs.coreutils}/bin/truncate -s 0 "$swapfile"
              ${pkgs.e2fsprogs}/bin/chattr +C "$swapfile"
          fi
        '';
      };
    };

    swapDevices = [ {
      device = cfg.path;
      randomEncryption.enable = cfg.encrypt;
      size = cfg.size+"*1024";
    } ];
  };
}