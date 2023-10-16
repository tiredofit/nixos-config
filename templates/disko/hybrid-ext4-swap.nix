let
  disk1 = "/dev/vda";
in
{
  disko.devices = {
    disk = {
      ${disk1} = {
        type = "disk";
        device = "${disk1}";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "boot";
              start = "0";
              end = "1M";
              flags = [ "bios_grub" ];
            }
            {
              name = "ESP";
              start = "1M";
              end = "512M";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            swap = {
              size = "4G"; # SWAP - Do not Delete this comment
              content = {
                type = "swap";
                randomEncryption = true;
                resumeDevice = true;
              };
            };
            {
              name = "root";
              start = "512M";
              end = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
          ];
        };
      };
    };
  };
}
