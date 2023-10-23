{ config, inputs, outputs, lib, pkgs, ... }:
  with lib;
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./locale.nix
    ./nix.nix
    ../../../users
  ] ++ (builtins.attrValues outputs.nixosModules);

  boot = {
    initrd = {
      compressor = mkDefault "zstd";
      compressorArgs = mkDefault ["-19"];

      systemd = {
        strip = mkDefault true;                               # Saves considerable space in initrd
      };
    };
    kernel.sysctl = {
      "vm.dirty_ratio" = mkDefault 6;                         # sync disk when buffer reach 6% of memory
    };
    kernelPackages = pkgs.linuxPackages_latest;               # Latest kernel
  };

  environment = {
    defaultPackages = []; # Don't install any default programs, force everything
    enableAllTerminfo = mkDefault false;
  };

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  hardware.enableRedistributableFirmware = mkDefault true;

  host = {
    application = {
      bash.enable = mkDefault true;
      bind.enable = mkDefault true;
      binutils.enable = mkDefault true;
      coreutils.enable = mkDefault true;
      curl.enable = mkDefault true;
      diceware.enable = mkDefault true;
      dust.enable = mkDefault true;
      git.enable = mkDefault true;
      htop.enable = mkDefault true;
      iftop.enable = mkDefault true;
      inetutils.enable = mkDefault true;
      iotop.enable = mkDefault true;
      kitty.enable = mkDefault true;
      less.enable = mkDefault true;
      links.enable = mkDefault true;
      lsof.enable = mkDefault true;
      mtr.enable = mkDefault true;
      nano.enable = mkDefault true;
      ncdu.enable = mkDefault true;
      pciutils.enable = mkDefault true;
      psmisc.enable = mkDefault true;
      rsync.enable = mkDefault true;
      strace.enable = mkDefault true;
      tmux.enable = mkDefault true;
      wget.enable = mkDefault true;
    };
    feature = {
      secrets.enable = mkDefault true;
    };
    service = {
      logrotate = {
        enable = mkDefault true;
      };
      ssh = {
        enable = mkDefault true;
        harden = mkDefault true;
      };
    };
  };

  networking.domain = mkDefault "tiredofit.ca";

  # Increase open file limit for sudoers
  security.pam.loginLimits = [
    {
      domain = "@wheel";
      item = "nofile";
      type = "soft";
      value = "524288";
    }
    {
      domain = "@wheel";
      item = "nofile";
      type = "hard";
      value = "1048576";
    }
  ];

  security.sudo.wheelNeedsPassword = mkDefault false ;

  services.fstrim.enable = mkDefault true;
  users.mutableUsers = mkDefault false;
}
