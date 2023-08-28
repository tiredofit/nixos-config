{ config, pkgs, lib, ... }:
with lib;

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";      # use TCP BBR has significantly increased throughput and reduced latency for connections
  };

  documentation = {                                 # This makes some nix commands not display --help
    enable = mkDefault false;
    info.enable = mkDefault false;
    man.enable = mkDefault false;
    nixos.enable = mkDefault false;
  };

  environment.variables.BROWSER = "echo";           # Print the URL instead on servers

  fonts.fontconfig.enable = lib.mkDefault false;    # No GUI
  host = {
    hardware = {
      sound.enable = false;                         # No sound on servers
      bluetooth.enable = mkDefault false;           # No bluetooth on servers
    };
  };

  networking.firewall.enable = true;                # Make sure firewall is enabled

  programs.nano.defaultEditor = lib.mkDefault true;

  systemd = {
    enableEmergencyMode = false;                    # Allow system to continue booting in headless mode.
    watchdog = {                                    # See https://0pointer.de/blog/projects/watchdog.html
      runtimeTime = "20s";                          # Hardware watchdog reboot after 20s
      rebootTime = "30s";                           # Force reboot when hangs after 30s. See https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
    };

    sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
    '';
  };


}
