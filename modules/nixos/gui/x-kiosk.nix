{ pkgs, config, specialArgs, ...}:
let
  inherit (specialArgs) kioskUsername kioskURL;
  autostart = ''
  #!${pkgs.bash}/bin/bash
  ${pkgs.firefox}/bin/firefox --kiosk https://www.tiredofit.ca/ &
  '';

  inherit (pkgs) writeScript;
in
{
  services.xserver = {
    enable = true;
    layout = "us";
    libinput.enable = true;

    displayManager.lightdm = {
      enable = true;
      # autoLogin = {
      #   timeout = 0;
      # };
    };

    windowManager.openbox.enable = true;
    displayManager = {
      defaultSession = "none+openbox";
      autoLogin = {
        user = "${kioskUsername}";
        enable = true;
      };
    };
  };

  systemd.services."display-manager".after = [
    "network-online.target"
    "systemd-resolved.service"
  ];

  # Overlay to set custom autostart script for openbox
  nixpkgs.overlays = with pkgs; [
    (_self: super: {
      openbox = super.openbox.overrideAttrs (_oldAttrs: rec {
        postFixup = ''
          ln -sf /etc/openbox/autostart $out/etc/xdg/openbox/autostart
        '';
      });
    })
  ];

  # By defining the script source outside of the overlay, we don't have to
  # rebuild the package every time we change the startup script.
  environment.etc."openbox/autostart".source = writeScript "autostart" autostart;
}
