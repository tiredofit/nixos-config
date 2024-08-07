{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.boot.initrd;
in
  with lib;
{
  options = {
    host.feature.boot.initrd = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = "Enables Initrd management via these options";
      };
      boot = mkOption {
        default = true;
        type = types.bool;
        description = "Whether to enable the NixOS initial RAM disk (initrd). This may be needed to perform some initialisation tasks (like mounting network/encrypted file systems) before continuing the boot process.";
      };
      compression = {
        type = mkOption {
          default = "zstd";
          type = types.enum [ "cat" "bzip2" "gzip" "zstd" "xz" ];
          description = "Initrd Compression type";
        };
        arguments = mkOption {
          default = null;
          type = types.nullOr (types.listOf types.str);
          description = "Arguments to pass to the compressor for the initrd image, or null to use the compressor's defaults.";
        };
      };
      modules = mkOption {
        type = types.listOf types.anything;
        default = [];
        description = "The set of kernel modules to be loaded in the second stage of the boot process";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      initrd = {
        compressor = mkDefault cfg.compression.type;
        compressorArgs = mkDefault [ "-19" ];

        enable = mkDefault cfg.boot;

        kernelModules = [] ++ cfg.modules;

        ## TODO - Bring over Systemd setttings
      };
    };
  };
}
