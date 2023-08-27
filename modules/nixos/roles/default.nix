{config, lib, pkgs, ...}:
with lib;
{
  options = {
    host.role = mkOption {
    # the type of the device
    # laptop and desktop include mostly common modules, but laptop has battery
    # optimizations on top of common programs
    # server has services I would want on a server, and lite is for low-end devices
    # that need only the basics
    # hybrid is for desktops that are also servers (my homelabs, basically)
    # vms are for quick dirty tests, lighter than the "lite" configuration
      type = mkOption {
        type = types.enum ["laptop" "desktop" "server" "kiosk" "hybrid" "lite" "vm"];
      };
      ## TODO add host.role.kiosk.url and host.role.kiosk.browser
    };
  };
}
