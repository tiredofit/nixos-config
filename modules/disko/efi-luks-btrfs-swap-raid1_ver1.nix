let
  rawdisk1 = "vda";
  rawdisk2 = "vdb";
  cryptdisk1 = "pool0_0";
  cryptdisk2 = "pool0_1";
in
{
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
              type = "EF00" ;
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
                resumeDevice = true;   # resume from hiberation from this device
              };
            };
            luks = {
              label = "enc_"+"${cryptdisk1}" ;
              size = "100%";
              content = {
                type = "luks";
                name = "${cryptdisk1}";
                extraOpenArgs = [ "--allow-discards" ];
                # if you want to use the key for interactive login be sure there is no trailing newline
                # for example use `echo -n "password" > /tmp/secret.key`
                keyFile = "/tmp/secret.key"; # Interactive
                # or file based
                #settings.keyFile = "/tmp/secret.key";
                #additionalKeyFiles = ["/tmp/additionalSecret.key"];
              };
            };
          };
        };
      };
      ${rawdisk2} = {
         device = "/dev/${rawdisk2}";
         type = "disk";
         content = {
           type = "luks";
           name = "${cryptdisk2}";
           extraOpenArgs = [ "--allow-discards" ];
           # if you want to use the key for interactive login be sure there is no trailing newline
           # for example use `echo -n "password" > /tmp/secret.key`
           keyFile = "/tmp/secret.key"; # Interactive
           # or file based
           #settings.keyFile = "/tmp/secret.key";
           #additionalKeyFiles = ["/tmp/additionalSecret.key"];
           content = {
             type = "btrfs";
             extraArgs = [ "-f" "-m raid1 -d raid1" "/dev/mapper/${cryptdisk1}" "/dev/mapper/${cryptdisk2}" ];
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
               "/home/snapshot" = {
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
               "/var_local" = {
                 mountpoint = "/var/local";
                 mountOptions = [ "compress=zstd" "noatime" ];
               };
                "/var_local/active" = {
                  mountpoint = "/var/local";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/var_local/snapshot" = {
                  mountpoint = "/var/local/.snapshots";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
             };
           };
         };
       };
     };
   };
}

