{lib, ...}:

with lib;
{
  imports = [
    ./desktop
    ./kiosk
    ./laptop
    ./minimal
    ./server
    ./vm
  ];

  options = {
    host.role = mkOption {
      type = types.enum [
        "desktop"   # Typical Workstation
        "hybrid"    # A mixture of a laptop or desktop - Special purpose
        "kiosk"     # Does one thing and one thing well
        "laptop"    # Workstation with differnet power profiles
        "minimal"   # Bare bones
        "server"    #
        "vm"        # Some sort of virtual machine, that may have a combo of desktop or laptop
      ];
    };
  };
}
