let
  rawdisk1 = "vda"; # CHANGE
  rawdisk2 = "vdb"; # CHANGE
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
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              label = "encrypted_swap"
              size = "4G"; # SWAP - Do not Delete this comment
              content = {
                type = "luks";
                name = "swap";
                extraOpenArgs = [ "--alow-discards" ];
                passwordFile = "/tmp/secret.key";
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            };
            luks = {
              label = "enc_" + "${cryptdisk1}";
              size = "100%";
              content = {
                type = "luks";
                name = "${cryptdisk1}";
                extraOpenArgs = [ "--allow-discards" ];
                passwordFile = "/tmp/secret.key"; # Interactive
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
                passwordFile = "/tmp/secret.key"; # Interactive
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
                    "/var_local" = {
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
