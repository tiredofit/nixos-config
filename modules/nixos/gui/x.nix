{ config, pkgs, ... }:


{
  imports =
    [
      ./fonts.nix
      ../locale.nix
      ../sound-pulseaudio.nix
    ];

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  environment.systemPackages = with pkgs; [
    acpi             # battery information
  ];

  programs = {
    dconf.enable = true;
  };

  services.xserver = {
     enable = true;

    desktopManager = {
      xterm.enable = false;
      session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];
    };

    displayManager = {
      startx.enable = true ;
      lightdm.enable = false ;
      gdm = {
        enable = true ;
        wayland = false ;
      };
    };

    layout = "us";
    libinput.enable = true;
    xkbVariant = "";
  };

  services = {
    gvfs.enable = true;    # Mount, trash, and other functionalities
  };
}

