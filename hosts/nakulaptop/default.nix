{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur
    ./hardware-configuration.nix

    ../common/global
  ];

  boot = {
    kernelParams = [
      "quiet"
    ];
  };

  host = {
    feature = {
      gaming = {
        enable = true;
        steam = {
          enable = true;
          protonGE = true;
        };
      };
      graphics = {
        enable = true;
        backend = "x";
      };
    };
    filesystem = {
      swap = {
        partition = "disk/by-uuid/2ad5730c-1905-4a4a-9d9b-7d53d28f1761";
      };
    };
    hardware = {
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
