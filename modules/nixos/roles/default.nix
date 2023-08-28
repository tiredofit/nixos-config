{lib, ...}:

with lib;
{
  imports = [
    ./desktop.nix
    ./hybrid.nix
    ./kiosk.nix
    ./laptop.nix
    ./hybrid.nix
    ./lite.nix
    ./vm.nix
  ];

  options = {
    host.role = mkOption {
      type = types.enum [
        "desktop"   # Typical Workstation
        "hybrid"    # A mixture of a laptop or desktop - Special purpose
        "kiosk"     # Does one thing and one thing well
        "laptop"    # Workstation with differnet power profiles
        "lite"      # Similar to VM, but more bare bones
        "server"    #
        "vm"        # Some sort of virtual machine, that may have a combo of desktop or laptop
      ];
    };
  };
}
