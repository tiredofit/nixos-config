{ config, lib, pkgs, modulesPath, ... }:


{
  imports = [
   (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "ehci_pci"
      "sd_mod"
      "sr_mod"
      "uhci_hcd"
      "vmw_pvscsi"
    ];
  };
}
