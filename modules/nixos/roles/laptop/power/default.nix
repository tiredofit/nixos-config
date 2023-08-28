{ config, lib, ...}:

let
  MHz = x: x * 1000;
  role = config.host.role;
in
  with lib;
  {
    config = mkIf (role == "laptop" || role == "hybrid") {
      boot = {
        kernelModules = ["acpi_call"];
        extraModulePackages = with config.boot.kernelPackages; [
          acpi_call
          cpupower
          pkgs.cpupower-gui
        ];
      };

      environment.systemPackages = with pkgs; [
        acpi
        powertop
      ];

      hardware.acpilight.enable = true;

      services = {
        # superior power management
        auto-cpufreq.enable = true;
        #power-profiles-daemon.enable = !config.host.features.powermanagement.laptop.enable;

        # temperature target on battery
        undervolt = {
          tempBat = 65; # deg C
          package = pkgs.undervolt;
        };

        auto-cpufreq.settings = {
          battery = {
            governor = "powersave";
            scaling_min_freq = mkDefault (MHz 1200);
          scaling_max_freq = mkDefault (MHz 1800);
          turbo = "never";
        };
        charger = {
          governor = "performance";
          scaling_min_freq = mkDefault (MHz 1800);
          scaling_max_freq = mkDefault (MHz 3000);
          turbo = "auto";
        };
      };

      udev.extraRules = let
        inherit (import ./plug_state.nix args) plugged unplugged;
      in ''
        # start/stop services on power (un)plug
        SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${plugged}"
        SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${unplugged}"
      '';
      # DBus service that provides power management support to applications.
      upower = {
        enable = true;
        percentageLow = 15;
        percentageCritical = 5;
        percentageAction = 3;
        criticalPowerAction = "Hibernate";
      };
    };
  };
}
