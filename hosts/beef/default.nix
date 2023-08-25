{ pkgs, inputs, ...}: {

  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-cpu-amd-raphael-igpu
    inputs.hardware.nixosModules.common-pc-hdd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.nur.nixosModules.nur
    inputs.vscode-server.nixosModules.default
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/gui/graphics-acceleration.nix
    ../common/optional/gui/x.nix

    ../common/optional/cross_compile-aarch64.nix
    ../common/optional/services/fail2ban.nix
    #../common/optional/services/opensnitch.nix
    ../common/optional/plymouth.nix
    ../common/optional/steam.nix
    ../common/optional/services/tailscale.nix
    ../common/optional/services/virtualization-docker.nix
    ../common/optional/services/virtualization-virt-manager.nix
    ../common/optional/services/vscode-server.nix

    ../../users/dave
    ../../users/root
  ];

  boot = {
    initrd.luks.devices = {
      "pool0_0" = {
         allowDiscards = true;
         bypassWorkqueues = true;
      };
      "pool0_1" = {
         allowDiscards = true;
         bypassWorkqueues = true;
      };
    };

    kernelParams = [
      "quiet"
      "video=DP-3:2560x1440@120"
      "video=DP-2:2560x1440@120"
      "video=HDMI-1:2560x1440@120"
      "amdgpu.sg_display=0"
    ];
  };

  host = {
    hardware = {
      bluetooth = enable;
    };
  };

  hostoptions = {
    boot-efi.enable = true;
    btrfs.enable = true;
    docker_container_manager.enable = true;
    encryption.enable = true;
    impermanence.enable = true;
    powermanagement.enable = true;
    printing.enable = true;
    raid.enable = true;
  };

  networking = {
    hostName = "beef";
    networkmanager= {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
