{config, lib, pkgs, ...}:
let
  cfg = config.host.application.bash;
  shellAliases = {
    ".." = "cd .." ;
    "..." = "cd ..." ;
    home = "cd ~" ;
    fuck = "sudo $(history -p !!)" ;                                    # run last command as root
    mkdir = "mkdir -p" ;                                                # no error, create parents
    scstart = "systemctl start $@";                                     # systemd service start
    scstop = "systemctl stop $@";                                       # systemd service stop
    scenable = "systemctl disable $@";                                  # systemd service enable
    scdisable = "systemctl disable $@";                                 # systemd service disable
  };
in
  with lib;
{
  options = {
    host.application.bash = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables bash";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bashInteractive # bash shell
    ];

    programs = {
      bash = {
        enableCompletion = true ;
        inherit shellAliases;
        shellInit = ''
              ## History
              export HISTFILE=/$HOME/.bash_history
              ## Configure bash to append (rather than overwrite history)
              shopt -s histappend

              # Attempt to save all lines of a multiple-line command in the same entry
              shopt -s cmdhist

              ## After each command, append to the history file and reread it
              export PROMPT_COMMAND="''${PROMPT_COMMAND:+$PROMPT_COMMAND$"\n"}history -a; history -c; history -r"

              ## Print the timestamp of each command
              HISTTIMEFORMAT="%Y%m%d.%H%M%S%z "

              ## Set History File Size
              HISTFILESIZE=2000000

              ## Set History Size in memory
              HISTSIZE=3000

              ## Don't save ls,ps, history commands
              export HISTIGNORE="ls:ll:ls -alh:pwd:clear:history:ps"

              ## Do not store a duplicate of the last entered command and any commands prefixed with a space
              HISTCONTROL=ignoreboth

              if [ -d "/var/local/data" ] ; then
                  alias vld='cd /var/local/data'
              fi

              if [ -d "/var/local/db" ] ; then
                  alias vldb='cd /var/local/db'
              fi

              if [ -d "/var/local/data/_system" ] ; then
                  alias vlds='cd /var/local/data/_system'
              fi

              if command -v "nmcli" &>/dev/null; then
                  alias wifi_scan="nmcli device wifi rescan && nmcli device wifi list"  # rescan for network
              fi

              if command -v "curl" &>/dev/null; then
                  alias derp="curl https://cht.sh/$1"                       # short and sweet command lookup
              fi

              if command -v "grep" &>/dev/null; then
                  alias grep="grep --color=auto"                            # Colorize grep
              fi

              if command -v "netstat" &>/dev/null; then
                  alias ports="netstat -tulanp"                             # Show Open Ports
              fi

              if command -v "tree" &>/dev/null; then
                  alias tree="tree -Cs"
              fi

              if command -v "rsync" &>/dev/null; then
                  alias rsync="rsync -aXxtv"                                # Better copying with Rsync
              fi

              if command -v "rg" &>/dev/null && command -v "fzf" &>/dev/null && command -v "bat" &>/dev/null; then
                function frg {
                  result=$(rg --ignore-case --color=always --line-number --no-heading "$@" |
                    fzf --ansi \
                        --color 'hl:-1:underline,hl+:-1:underline:reverse' \
                        --delimiter ':' \
                        --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
                        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
                  file="''${result%%:*}"
                  linenumber=$(echo "''${result}" | cut -d: -f2)
                  if [ ! -z "$file" ]; then
                          $EDITOR +"''${linenumber}" "$file"
                  fi
                }
              fi

              if [ -d "$HOME/.bashrc.d" ] ; then
                for script in $HOME/.bashrc.d/* ; do
                    source $script
                done
              fi

              # Quickly run a pkg run nixpkgs - Add a second argument to it otherwise it will simply run the command
              pkgrun () {
                  if [ -n $1 ] ; then
                     local pkg
                     pkg=$1
                     if [ "$2" != "" ] ; then
                         shift
                         local args

                         args="$@"
                     else
                         args=$pkg
                     fi

                     nix-shell -p $pkg.out --run "$args"
                  fi
              }

        '';
      };
    };
  };
}
