{ config, inputs, outputs, lib, pkgs, self, ... }:
  with lib;
{
  imports = [
    inputs.nix-modules.nixosModules
    ./locale.nix
    ./nix.nix
    ../../users
  ];


  boot = {
    initrd = {
      systemd = {
        #strip = mkDefault true;                         # Saves considerable space in initrd
      };
    };
    kernel.sysctl = {
      "vm.dirty_ratio" = mkDefault 6;                   # sync disk when buffer reach 6% of memory
    };
  };

  environment = {
    defaultPackages = [];                               # Don't install any default programs, force everything
    enableAllTerminfo = mkDefault false;
  };

  hardware.enableRedistributableFirmware = mkDefault true;
  host = {
    application = {
      bash.enable = mkDefault true;
      bind.enable = mkDefault true;
      binutils.enable = mkDefault true;
      coreutils.enable = mkDefault true;
      curl.enable = mkDefault true;
      diceware.enable = mkDefault true;
      dust.enable = mkDefault true;
      e2fsprogs.enable = mkDefault true;
      fzf.enable = mkDefault true;
      git.enable = mkDefault true;
      htop.enable = mkDefault true;
      iftop.enable = mkDefault true;
      inetutils.enable = mkDefault true;
      iotop.enable = mkDefault true;
      kitty.enable = mkDefault true;
      lazydocker.enable = mkDefault true;
      less.enable = mkDefault true;
      links.enable = mkDefault true;
      liquidprompt.enable = mkDefault true;
      lsof.enable = mkDefault true;
      lnav.enable = mkDefault true;
      mtr.enable = mkDefault true;
      nano.enable = mkDefault true;
      ncdu.enable = mkDefault true;
      pciutils.enable = mkDefault true;
      psmisc.enable = mkDefault true;
      ripgrep.enable = mkDefault true;
      rsync.enable = mkDefault true;
      strace.enable = mkDefault true;
      tmux.enable = mkDefault true;
      wget.enable = mkDefault true;
      zoxide.enable = mkDefault true;
    };
    configDir = self.outPath;
    feature = {
      home-manager.enable = mkDefault true;
      secrets.enable = mkDefault true;
    };
    network = {
      domainname = mkDefault "tiredofit.ca";
    };
    service = {
      herald = {
        general = {
          log_level = mkDefault "verbose";
        };
        inputs = {
          docker_pub = mkDefault {
            type = "docker";
            api_url = "unix:///var/run/docker.sock";
            expose_containers = false;
            process_existing = true;
            record_remove_on_stop = true;
            filter = [
              {
                type = "label";
                conditions = [
                  {
                    key = "traefik.proxy.visibility";
                    value = "public";
                  }
                  {
                    key = "traefik.proxy.visibility";
                    value = "any";
                    logic = "or";
                  }
                ];
              }
            ];
          };
          docker_int = mkDefault {
            type = "docker";
            api_url = "unix:///var/run/docker.sock";
            expose_containers = false;
            process_existing = true;
            record_remove_on_stop = true;
            filter = [
              {
                type = "label";
                conditions = [
                  {
                    key = "traefik.proxy.visibility";
                    value = "internal";
                  }
                  {
                    key = "traefik.proxy.visibility";
                    value = "any";
                    logic = "or";
                  }
                ];
              }
            ];
          };
        };
        domains = {
          domain01 = mkDefault {
            profiles = {
              inputs = [ "docker_pub" ];
              outputs = [ "output01" ];
            };
          };
          domain02 = mkDefault {
            profiles = {
              inputs = [ "docker_int" ];
              outputs = [ "output02"];
            };
          };
        };
      };
      logrotate = {
        enable = mkDefault true;
      };
      ssh = {
        enable = mkDefault true;
        harden = mkDefault true;
      };
    };
  };

  security = {
    pam.loginLimits = [
      # Increase open file limit for sudoers
      {
        domain = "@wheel";
        item = "nofile";
        type = "soft";
        value = "524288";
      }
      {
        domain = "@wheel";
        item = "nofile";
        type = "hard";
        value = "1048576";
      }
    ];
    sudo.wheelNeedsPassword = mkDefault false;
  };

  services.fstrim.enable = mkDefault true;
  users.mutableUsers = mkDefault false;
}
