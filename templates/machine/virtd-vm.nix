{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
   (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "sr_mod"
      "virtio_blk"
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];
  };
}
