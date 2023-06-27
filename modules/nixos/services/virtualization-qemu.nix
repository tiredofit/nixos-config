{ config, pkgs, ... }:
{
  boot = {
    extraModprobeConfig = "options kvm_amd nested=1";
    kernelModules = [ "kvm_amd" ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
  };
}
