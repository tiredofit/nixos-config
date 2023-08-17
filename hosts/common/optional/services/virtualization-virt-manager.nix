{ config, lib, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
   virt-manager
   spice-gtk
   swtpm
  ];

  programs.dconf.enable = true;
  security.polkit.enable = true;

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    spiceUSBRedirection.enable = true;
  };

  hostoptions.impermanence.directories = lib.mkIf config.hostoptions.impermanence.enable [
    "/var/lib/libvirt"                 # Libvirt
  ];
}
