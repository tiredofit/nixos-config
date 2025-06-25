{ config, inputs, lib, pkgs, ...}: {

  imports = [
    ./hardware-configuration.nix
    ../common
  ];

  host.feature.virtualization.docker.containers.restic.resources.memory.max = "3G";
  host = {
    container = {
      coredns = {
        enable = true;
        logship = false;
        monitor = false;
        ports = {
          tcp = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          udp = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
      restic = {
        enable = true;
        logship = false;
        monitor = false;
      };
      socket-proxy = {
        enable = true;
        logship = false;
        monitor = false;
      };
      traefik = {
        enable = true;
        logship = false;
        monitor = false;
        ports = {
          http = {
            enable = true;
            method = "interface";
            excludeInterfaces = [ "lo" ];
            excludeInterfacePattern = "docker|veth|br-";
          };
          https = {
            enable = true;
            method = "interface";
            excludeInterfaces = [ "lo" ];
            excludeInterfacePattern = "docker|veth|br-";
          };
          http3 = {
            enable = true;
            method = "interface";
            excludeInterfaces = [ "lo" ];
            excludeInterfacePattern = "docker|veth|br-";
          };
        };
      };
      traefik-internal = {
        enable = true;
        logship = false;
        monitor = false;
        ports = {
          http = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          https = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
          http3 = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };
      zabbix-proxy = {
        enable = false;
        logship = false;
        monitor = false;
        ports = {
          proxy = {
            enable = true;
            method = "zerotier";
            zerotierNetwork = "file:///var/run/secrets/zerotier/networks";
          };
        };
      };

    };
    feature = {
      appimage.enable = true;
      development.crosscompilation.enable = true;
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "greetd";
        windowManager.manager = "hyprland";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
        virtd = {
          daemon.enable = true;
        };
        docker = {
          enable = true;
        };
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
      firmware.enable = true;
    };
    network = {
      firewall = {
        opensnitch.enable = true;
      };
      hostname = "nomad";
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "/var/run/secrets/zerotier/networks"
          ];
          port = 9993;
        };
      };
    };
    role = "laptop";
    service = {
      herald = {
        enable = true;
        general = {
          log_level = "verbose";
          skip_domain_validation = true;
        };
        inputs = {
          docker_pub = {
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
                ];
              }
            ];
          };
          docker_int = {
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
                ];
              }
            ];
          };
        };
        domains = {
          domain01 = {
            profiles = {
              inputs = [ "docker_pub" ];
              outputs = [ "output01" ];
            };
          };
          domain02 = {
            profiles = {
              inputs = [ "docker_int" ];
              outputs = [ "output02"];
            };
          };
        };
      };
      zeroplex = {
        enable = true;
      };
    };
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };

    networking.firewall.allowedTCPPorts = [ 8080 1053 ];
}