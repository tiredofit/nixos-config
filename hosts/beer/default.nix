{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/nixos/default.nix
      ../../modules/nixos/services/openssh.nix
      ../../modules/nixos/gui/x-kiosk.nix
    ];

  boot = {
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };

  networking = {
    hostName = "beer";
    networkmanager.enable = true;
  };

  nix.settings.trusted-users = [ "root" "@wheel" "dave" ];
  system.stateVersion = "23.05";
}

## config.txt
## config.txt
## See /boot/overlays/README for all available options
#
#initramfs initramfs-linux.img followkernel

#dtoverlay=vc4-fkms-v3d # or vc4-kms-v3d or nothing
#hdmi_force_hotplug=1
#hdmi_timings=2560 0 48 32 80 1080 0 7 20 12 0 0 0 52 0 159838855 7
#hdmi_group=2
#hdmi_mode=87
#hdmi_drive=2
#framebuffer_width=2560
#max_framebuffer_width=2560
#framebuffer_height=1080
#hdmi_pixel_freq_limit=160000000
#
#display_auto_detect=1

## Uncomment to enable bluetooth
##dtparam=krnbt=on
#
#[pi3]
#dtoverlay=rpi3-hdmi

#[pi4]
## Run as fast as firmware / board allows
#arm_boost=1# See /boot/overlays/README for all available options

