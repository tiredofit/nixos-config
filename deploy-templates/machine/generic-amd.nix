{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [

  ];

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "nvme"
      "sd_mod"
      "sr_mod"
      "usb_storage"
      "usbhid"
      "xhci_pci"
    ];
  };
}
