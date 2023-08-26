{ pkgs, inputs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix

    ../common/global

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
    feature = {
      boot = {
        efi.enable = true;
        graphical.enable = true;
      };
      development = {
        crosscompilation = {
          enable = true;
          platform = "aarch64-linux";
        };
      };
      displayManager = {
        server = "x";
      };
      gaming = {
        enable = true;
        steam.enable = true;
      };
      powermanagement.enable = true;
      virtualization = {
        docker = {
          enable = true;
        };
        virtd = {
          client.enable = true;
          daemon.enable = true;
        };
      };
    };
    filesystem = {
      btrfs.enable = true;
      encryption.enable = true;
      impermanence.enable = true;
    };
    hardware = {
      bluetooth.enable = true;
      cpu = "amd";
      graphics = {
        acceleration = true;
        displayServer = "x";
        gpu = "integrated-amd";
      };
      printing.enable = true;
      sound = {
        enable = true;
        server = "pulseaudio";
      };
      wireless.enable = true;
      raid.enable = true;
    };
    network = {
      firewall = {
        fail2ban.enable = true;
        opensnitch.enable = false;
      };
      vpn = {
        tailscale.enable = true;
      };
    };
    #
    service = {
       vscode_server.enable = true;
    };
  };

  networking = {
    hostName = "beef";
    networkmanager= {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
