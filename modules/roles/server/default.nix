{ config, lib, modulesPath, pkgs, ... }:
let
  role = config.host.role;
in
  with lib;
{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = mkIf (role == "server") {
    boot = {
      initrd = mkDefault {
        checkJournalingFS = false;                      # Get the server up as fast as possible
      };

      kernel.sysctl =  mkDefault {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";    # use TCP BBR has significantly increased throughput and reduced latency for connections
      };
    };

    documentation = {                                 # This makes some nix commands not display --help
      enable = mkDefault false;
      info.enable = mkDefault false;
      man.enable = mkDefault false;
      nixos.enable = mkDefault false;
    };

    environment.variables.BROWSER = "echo";           # Print the URL instead on servers

    fonts.fontconfig.enable = mkDefault false;        # No GUI

    host = {
      feature = {
        boot = {
          efi.enable = mkDefault true;
          graphical.enable = mkDefault false;
        };
        graphics = {
          enable = mkDefault false;                   # Maybe if we were doing openCL
        };
        virtualization = {
          docker = {
            enable = mkDefault true;
          };
        };
      };
      filesystem = {
        btrfs.enable = mkDefault true;
        encryption.enable = mkDefault true;
        impermanence = {
          enable = mkDefault true;
          directories = [

          ];
        };
        swap = {
          enable = mkDefault true;
          type = mkDefault "partition";
        };
      };
      hardware = {
        bluetooth.enable = mkDefault false;
        printing.enable = mkDefault false;            # My use case never involves a print server
        raid.enable = mkDefault false;
        scanning.enable = mkDefault false;
        sound.enable = mkDefault false;
        webcam.enable = mkDefault false;
        wireless.enable = mkDefault false;            # Most servers are ethernet?
        yubikey.enable = mkDefault false;
      };
      network = {
        firewall.fail2ban.enable = mkDefault true;
        wired.enable = mkDefault true;
      };
      service = {
        logrotate.enable = mkDefault true;
        ssh = {
          enable = mkDefault true;
          harden = mkDefault true;
        };
      };
    };

    networking = {
      dhcpcd.enable = mkDefault false;                # Let's stay static
      enableIPv6 = mkDefault false;                   # See you in 2040
      firewall = {
        enable = mkDefault true;                      # Make sure firewall is enabled
        allowPing = mkDefault true;
        rejectPackets = mkDefault false;
        logRefusedPackets = mkDefault false;
        logRefusedConnections = mkDefault true;
      };
      networkmanager= {
        enable = mkDefault false;                     # systemd-networkd is cleaner and built in
      };
      useDHCP = mkDefault false;
      useNetworkd = mkDefault false;
    };

    systemd = {
      enableEmergencyMode = mkDefault false;          # Allow system to continue booting in headless mode.
      watchdog = mkDefault {                          # See https://0pointer.de/blog/projects/watchdog.html
        runtimeTime = "20s";                          # Hardware watchdog reboot after 20s
        rebootTime = "30s";                           # Force reboot when hangs after 30s. See https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
      };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };
  };
}
