{config, lib, pkgs, ...}:

let
  cfg_daemon = config.host.feature.virtualization.virtd.daemon;
  cfg_client = config.host.feature.virtualization.virtd.client;
in
  with lib;
  with pkgs;
{
  options = {
    host.feature.virtualization.virtd = {
      client = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Enables tools to manage virtd instances";
        };
      };
      daemon = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Enables virtd virtualiation daemon";
        };
      };
    };
  };

  config = lib.mkMerge [
  {
    environment.systemPackages = lib.mkIf cfg_client.enable [
      spice-gtk
      swtpm
      virt-manager
    ];


    virtualisation = lib.mkIf cfg_daemon.enable {
      libvirtd = {
        enable = true;
      };
      spiceUSBRedirection.enable = true;
    };

    programs.dconf = lib.mkIf cfg_daemon.enable {
      enable = true;
    };

    security = lib.mkIf cfg_daemon.enable {
      polkit.enable = true;
    };

    host.feature.impermanence.directories = lib.mkIf config.host.feature.impermanence.enable [
      "/var/lib/libvirt"                 # Libvirt
    ];

  }];
}

