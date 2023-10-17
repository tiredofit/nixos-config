let
  rawdisk1 = "/dev/vda"; # CHANGE
in
{
  disk = {
    ${rawdisk1} = {
      device = "${rawdisk1}";
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
          swap = {
            label = "swap";
            size = "4G"; # SWAP - Do not Delete this comment
            content = {
              type = "swap";
              randomEncryption = true;
              resumeDevice = true;
            };
          };
          luks = {
            label = "encrypted" ;
            size = "100%";
            content = {
              type = "luks";
              name = "pool0_0";
              extraOpenArgs = [ "--allow-discards" ];
              # if you want to use the key for interactive login be sure there is no trailing newline
              # for example use `echo -n "password" > /tmp/secret.key`
              keyFile = "/tmp/secret.key"; # Interactive
              # or file based
              #settings.keyFile = "/tmp/secret.key";
              #additionalKeyFiles = ["/tmp/additionalSecret.key"];
              keyFile = "/tmp/secret.key";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
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
}
