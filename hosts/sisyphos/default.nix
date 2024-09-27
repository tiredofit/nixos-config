{ config, inputs, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  host = {
    feature = {
      appimage.enable = true;
      boot = {
        kernel = {
          parameters = [
            "video=HDMI-1:1920x1080@120"
          ];
        };
      };
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "sddm";
        windowManager.manager = "hyprland";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
      };
    };
    filesystem = {
      encryption.enable = false;
      impermanence.enable = false;
      exfat.enable = true;
      ntfs.enable = true;
      swap = {
        partition = "disk/by-uuid/6402c381-6c93-4673-a78e-250752f15c9b";
      };
      tmp.tmpfs.enable = true;
    };
    hardware = {
      cpu = "amd";
      gpu = "integrated-amd";
      keyboard.enable = true;
      raid.enable = true;
      sound = {
        server = "pipewire";
      };
    };
    network = {
      firewall = {
        opensnitch.enable = false;
      };
      hostname = "sisyphos";
    };
    role = "laptop";
    user = {
      alex.enable = true;
      root.enable = true;
    };
  };
}
