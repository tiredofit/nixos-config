{ confg, inputs, outputs, lib, pkgs, ... }:
  with lib;
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./bash.nix
    ./diceware.nix
    ./less.nix
    ./locale.nix
    ./nix.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

  boot = {
    initrd = {
      systemd = {
        strip = mkDefault true;                               # Saves considerable space in initrd
      };
    };
    kernel.sysctl = {
      "vm.dirty_ratio" = mkDefault 6;                         # sync disk when buffer reach 6% of memory
    };
    kernelPackages = pkgs.linuxPackages_latest;     # Latest kernel

  };

  documentation = {
    doc.enable = mkDefault false;
    nixos.enable = mkDefault false;
    info.enable = mkDefault false;
    man = {
      enable = mkDefault true;
      generateCaches = mkDefault true;
    };
  };

  environment = {
    defaultPackages = []; # Don't install any default programs, force everything
    enableAllTerminfo = mkDefault true;
    systemPackages = with pkgs; [
      binutils            # standard binutils
      bind                # nslookup and nameserver tools
      coreutils           # gnu core utilities
      curl                # swiss army knife
      du-dust             # rust version of du
      git                 # git
      git-lfs             # git large file support
      htop                # process analysis
      iftop               # network i/o analysis
      inetutils           # internet tools
      iotop               # i/o analysis
      links2              # console web browser
      lsof                # list open files
      mtr                 # traceroute
      ncdu                # disk usage gui
      nano                # editor
      nvd                 # Nix Diffs
      psmisc              # process analysis
      rsync               # Transfer files
      wget                # file fetcher
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      pciutils            # pci statistics
      strace              # debug
    ]);
  };

  home-manager.extraSpecialArgs = { inherit inputs outputs; };

  hardware.enableRedistributableFirmware = mkDefault true;

  host = {
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
}
