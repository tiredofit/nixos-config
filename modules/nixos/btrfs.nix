{config, lib, pkgs, ...}:

let
  cfg_btrfs = config.hostoptions.btrfs;
in
  with lib;
{
  options = {
    hostoptions.btrfs = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Enables settings for a BTRFS installation including snapshots";
      };
    };
  };

  config = mkIf cfg_btrfs.enable {
    boot = {
      supportedFilesystems = [
        "btrfs"
      ];
    };

    fileSystems = {
      "/".options = [ "subvol=root" "compress=zstd" "noatime"  ];
      "/home".options = [ "subvol=home/active" "compress=zstd" "noatime"  ];
      "/home/.snapshots".options = [ "subvol=home/snapshots" "compress=zstd" "noatime"  ];
      "/nix".options = [ "subvol=nix" "compress=zstd" "noatime"  ];
      "/var/local".options = [ "subvol=var_local/active" "compress=zstd" "noatime"  ];
      "/var/local/.snapshots".options = [ "subvol=var_local/snapshots" "compress=zstd" "noatime"  ];
      "/var/log".options = [ "subvol=var_log" "compress=zstd" "noatime"  ];
      "/var/log".neededForBoot = true;
    };

    services = {
      btrbk = {
        instances."btrbak" = {
          onCalendar = "*-*-* *:00:00";
          settings = {
            timestamp_format = "long";
            snapshot_preserve_min = "2d";
            preserve_day_of_week = "sunday" ;
            preserve_hour_of_day = "0" ;
            target_preserve = "48h 10d 4w 12m 10y" ;
            volume."/home" = {
              snapshot_create = "always";
              subvolume = ".";
              snapshot_dir = ".snapshots";
            };
            volume."/var/local" = {
              snapshot_create = "always";
              subvolume = ".";
              snapshot_dir = ".snapshots";
            };
          };
        };
      };
    };
  };
}
