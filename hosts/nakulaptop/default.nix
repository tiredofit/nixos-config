{ config, inputs, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  host = {
    feature = {
      boot = {
        kernel = {
          parameters = [
            "quiet"
          ];
        };
      };
      graphics = {
        enable = true;
        backend = "x";
      };
      virtualization = {
        flatpak.enable = true;
      };
    };
    filesystem = {
      swap = {
        partition = "disk/by-uuid/2ad5730c-1905-4a4a-9d9b-7d53d28f1761";
      };
    };
    hardware = {
      backlight = {
        keys = {
          down = 232;
          up = 233;
        };
      };
      cpu = "amd";
      gpu = "integrated-amd";
      sound = {
        server = "pulseaudio";
      };
      touchpad = {
        asus-touchpad-numpad.enable = true;
      };
    };
    network = {
      hostname = "nakulaptop";
    };
    role = "laptop";
    user = {
      dave.enable = true;
      ireen.enable = true;
      root.enable = true;
    };
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      cinnamon.enable = true;
      xterm.enable = false;
      session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
        {
          name = "cinnamon";
          start = ''
            cinnamon
          '';
        }
      ];
    };
  };
}
