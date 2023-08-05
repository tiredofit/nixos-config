{ config, pkgs, ... }:

{
  imports = [
    ./bash.nix          # Bash Script
    ./diceware.nix      # Password Generator
    ./less.nix          # pager
  ];

  environment.systemPackages = with pkgs; [
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
    wget                # file fetcher
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      pciutils          # pci statistics
      strace            # debug
    ]);
}
