{ config, inputs, lib, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  host = {
    feature = {
      appimage.enable = true;
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "greetd";
        windowManager.manager = "hyprland";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
      };
    };
    filesystem = {
      encryption.enable = true;             # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;           # This line can be removed if not needed as it is already default set by the role template
      exfat.enable = true;
      ntfs.enable = true;
      swap = {
        partition = "disk/by-uuid/323a1f63-524e-4891-a428-fb42cf6c169a";
      };
      tmp.tmpfs.enable = true;
    };
    hardware = {
      cpu = "amd";
      gpu = "integrated-amd";
      sound = {
        server = "pipewire";
      };
    };
    network = {
      hostname = "nomad";
    };
    role = "laptop";
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };

    programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
    ];
  };
}
