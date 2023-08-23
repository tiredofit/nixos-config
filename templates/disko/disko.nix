let
  rawdisk1 = "vda";
  rawdisk2 = "vdb";
  cryptdisk1 = "pool0_0";
  cryptdisk2 = "pool0_1";
in {
  disko.devices = {
    disk = {
      ${rawdisk1} = {
        device = "/dev/${rawdisk1}";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              label = "swap";
              size = "4G";
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true;
              };
            };
            luks = {
              label = "enc_" + "${cryptdisk1}";
              size = "100%";
              content = {
                type = "luks";
                name = "${cryptdisk1}";
                extraOpenArgs = [ "--allow-discards" ];
                keyFile = "/tmp/secret.key"; # Interactive
              };
            };
          };
        };
      };
      ${rawdisk2} = {
        device = "/dev/${rawdisk2}";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              label = "enc_" + "${cryptdisk2}";
              size = "100%";
              content = {
                type = "luks";
                name = "${cryptdisk2}";
                extraOpenArgs = [ "--allow-discards" ];
                keyFile = "/tmp/secret.key"; # Interactive
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-m raid1 -d raid1"
                    "/dev/mapper/${cryptdisk1}"
                    "/dev/mapper/${cryptdisk2}"
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home/active" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home/snapshots" = {
                      mountpoint = "/home/.snapshots";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/persist/active" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/persist/snapshots" = {
                      mountpoint = "/persist/.snapshots";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var_local" = {
                      mountpoint = "/var/local";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var_local/active" = {
                      mountpoint = "/var/local";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var_local/snapshots" = {
                      mountpoint = "/var/local/.snapshots";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var_log" = {
                      mountpoint = "/var/log";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}