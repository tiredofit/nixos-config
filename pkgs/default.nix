pkgs: {
  asus-touchpad-numpad = pkgs.python3.pkgs.callPackage ./asus-touchpad-numpad { };
  zerotier-systemd-manager = pkgs.callPackage ./zerotier-systemd-manager { };
}