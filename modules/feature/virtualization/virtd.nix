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
    environment.systemPackages = mkIf cfg_client.enable [
      spice-gtk
      swtpm
      virt-manager
    ];

    virtualisation = {
      libvirtd = mkIf cfg_daemon.enable {
        enable = mkForce true;
      };
      spiceUSBRedirection = mkIf cfg_daemon.enable {
        enable = mkForce true;
      };
    };

    programs.dconf = mkIf cfg_daemon.enable {
      enable = true;
    };

    security = mkIf cfg_daemon.enable {
      polkit.enable = true;
    };

    host.filesystem.impermanence.directories = mkIf ((config.host.filesystem.impermanence.enable) && (cfg_client.enable)) [
      "/var/lib/libvirt"                 # Libvirt
    ];

  }];
}
