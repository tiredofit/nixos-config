#!/usr/bin/env bash

SCRIPT_VERSION=0.0.1

case "$1" in
    "--debug" )
            export DEBUG_MODE=TRUE
        ;;
    "--version" | "-v" )
            echo "${SCRIPT_VERSION}"
            exit 1
        ;;
    "--help" | "-h" | "-?" )
        printf "\033c"
        cat << EOF
****************************************************************************************************************************
** NixOS Installation Script - Revision ${SCRIPT_VERSION}
**
** - Based on a series of questions, this tool will setup a working NixOS Installtion from either a NixOS ISO
**   or an alternative operating system such as the OVH Rescue Image
**
** - Usage:
**   '$(basename $0)'                      - Interative Mode (Default)
**   '$(basename $0)' --help               - Yer lookin at it
**   '$(basename $0)' --debug              - Shows Output of commands behind the scenes
**   '$(basename $0)' --changelog          - Shows this tools Changelog
**   '$(basename $0)' --version            - Shows this tools version
**   '$(basename $0)' --(arguments)        - Pass any arguments to alter default behaviour
**
** -- Arguments:
**
****************************************************************************************************************************
EOF
        exit 99
        ;;
    "--changelog" | "-c" )
        if [ -f "$0"/CHANGELOG.md ] ; then
            cat "$0"/CHANGELOG.md
            exit 98
        else
            echo "Please see CHANGELOG.md in the source code repository"
            exit 98
        fi
    ;;
   *)
        :
    ;;
esac

# Check is Nix is installed
if ! command -v "nix" &>/dev/null; then
    echo "Nix is not installed!"
    exit 1
fi

########################################################################################
### System Functions                                                                 ###
########################################################################################
### Colours
# Foreground (Text) Colors
cdgy="\e[90m"      # Color Dark Gray
clg="\e[92m"       # Color Light Green
clm="\e[95m"       # Color Light Magenta
cwh="\e[97m"       # Color White

# Turns off all formatting
coff="\e[0m"       # Color Off

# Background Colors
bdr="\e[41m"       # Background Color Dark Red
bdg="\e[42m"       # Background Color Dark Green
bdb="\e[44m"       # Background Color Dark Blue
bdm="\e[45m"       # Background Color Dark Magenta
bdgy="\e[100m"     # Background Color Dark Gray
blr="\e[101m"      # Background Color Light Red
boff="\e[49m"      # Background Color Off


## An attempt to shut down so much noise specifically for echo statements
output_off() {
    if [ "${DEBUG_MODE,,}" = "true" ] ; then
        set +x
    fi
}

output_on() {
    if [ "${DEBUG_MODE,,}" = "true" ] ; then
        set -x
    fi
}

### Text Coloration
print_debug() {
    output_off
    case "$LOG_LEVEL" in
            "DEBUG" )
                if [ "${DEBUG_MODE,,}" = "true" ] ; then
                    if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
                        echo -e "[DEBUG] $SCRIPTPATH/$(basename "$0") **  $1"
                    else
                        echo -e "${bdm}[DEBUG]${boff} $SCRIPTPATH/$(basename "$0") **  $1"
                    fi
                else
                    if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
                        echo -e "[DEBUG] **  $1"
                    else
                        echo -e "${bdm}[DEBUG]${boff} **  $1"
                    fi
                fi
            ;;
    esac
    output_on
}

print_error() {
    output_off
    case "$LOG_LEVEL" in
            "DEBUG" | "NOTICE" | "WARN" | "ERROR")
                if [ "${DEBUG_MODE,,}" = "true" ] ; then
                    if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
                        echo -e "[ERROR] $SCRIPTPATH/$(basename "$0") **  $1"
                    else
                        echo -e "${blr}[ERROR]${boff} $SCRIPTPATH/$(basename "$0") **  $1"
                    fi
                else
                    if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
                        echo -e "[ERROR] **  $1"
                    else
                        echo -e "${blr}[ERROR]${boff} **  $1"
                    fi
                fi
            ;;
    esac
    output_on
}

print_info() {
    output_off
    if [ "${DEBUG_MODE,,}" = "true" ] ; then
        if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
            echo -e "[INFO] $SCRIPTPATH/$(basename "$0") **  $1"
        else
            echo -e "${bdg}[INFO]${boff} $SCRIPTPATH/$(basename "$0") **  $1"
        fi
    else
        if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
            echo -e "[INFO] **  $1"
        else
            echo -e "${bdg}[INFO]${boff} **  $1"
        fi
    fi
    output_on
}

print_notice() {
    output_off
    case "$LOG_LEVEL" in
            "DEBUG" | "NOTICE" )
                if [ "${DEBUG_MODE,,}" = "true" ] ; then
                    if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
                        echo -e "[NOTICE] $SCRIPTPATH/$(basename "$0") **  $1"
                    else
                        echo -e "${bdgy}[NOTICE]${boff} $SCRIPTPATH/$(basename "$0") **  $1"
                    fi
                else
                    if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
                        echo -e "[NOTICE] **  $1"
                    else
                        echo -e "${bdgy}[NOTICE]${boff} **  $1"
                    fi
                fi
            ;;
    esac
    output_on
}

print_warn() {
    output_off
    case "$LOG_LEVEL" in
            "DEBUG" | "NOTICE" | "WARN" )
                if [ "${DEBUG_MODE,,}" = "true" ] ; then
                    if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
                        echo -e "[WARN] **  $1"
                    else
                        echo -e "${bdb}[WARN]${boff} $SCRIPTPATH/$(basename "$0") **  $1"
                    fi
                else
                    if [ "${COLORIZE_OUTPUT,,}" = "false" ] ; then
                        echo -e "[WARN] **  $1"
                    else
                        echo -e "${bdb}[WARN]${boff} **  $1"
                    fi
                fi
    esac
    output_on
}

## Quiet down output
silent() {
  if [ "${SHOW_OUTPUT,,}" = "true" ] ;  then
    "$@"
  else
    "$@" > /dev/null 2>&1
  fi
}

valid_ip() {
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


## Timesaver for if statements
## Usage: if var_false $VARNAME ; then ... fi
var_false() {
    [ "${1,,}" = "false" ] || [ "${1,,}" = "no" ]
}

var_notfalse() {
    [ "${1,,}" != "false" ]
}

var_nottrue() {
    [ "${1,,}" != "true" ]
}

var_true() {
    [ "${1,,}" = "true" ] || [ "${1,,}" = "yes" ]
}

#########################################

check_dependencies() {
    set +e
    os=$(cat /etc/os-release |grep ^ID= | cut -d = -f 2)
    if ! type "git" > /dev/null 2>&1 ; then
        print_warn "[check_dependencies] git not found, installing.."
        case $os in
            "debian" )
                debian_version=$(cat /etc/os-release |grep ^VERSION_ID= | cut -d = -f 2 | cut -d '"' -f 2)
                case $debian_version in
                    *)
                        print_debug "[check_dependencies] Debian ${debian_version} detected"
                        silent sudo apt-get update
                        silent sudo apt-get install -y git
                        ;;
                esac
            ;;
            "arch" )
                sed -i "s|SigLevel .* = Required DatabaseOptional|SigLevel = Never|g" /etc/pacman.conf
                silent sudo pacman -Syy git --noconfirm
            ;;
        esac
    fi

    if ! type "nix" > /dev/null 2>&1 ; then
        print_warn "[check_dependencies] nix not found, installing.."
        case $os in
            "debian" )
                debian_version=$(cat /etc/os-release |grep ^VERSION_ID= | cut -d = -f 2 | cut -d '"' -f 2)
                case $debian_version in
                    *)
                        print_debug "[check_dependencies] Debian ${debian_version} detected"
                        silent sudo  sudo install -d -m755 -o $(id -u) -g $(id -g) /nix
                        silent curl -L https://nixos.org/nix/install | sh
                        source $HOME/.nix-profile/etc/profile.d/nix.sh
                        ## TODO - Rootless Install https://nixos.wiki/wiki/Nix_Installation_Guide
                        ;;
                esac
            ;;
            "arch" )
                sed -i "s|SigLevel .* = Required DatabaseOptional|SigLevel = Never|g" /etc/pacman.conf
                silent sudo pacman -Syy nix --noconfirm
            ;;
        esac
    fi
    set -e
}

questions() {
    printf "\033c"
    print_info "Starting NixOS Deployment Script at $(TZ=${TIMEZONE} date -d @${script_start_time} '+%Y-%m-%d %H:%M:%S')"
    echo -e "${clm}"
    cat << EOF
--------------------------
| NiXOS Deployment ${SCRIPT_VERSION} |
--------------------------

** WARNING ** This script will eat your cat if you aren't careful.
EOF
    echo -e "${coff}"

    COLUMNS=12
    prompt="What do you want to do?"
    options=( "Update Flake" "Update System" )
    PS3="$prompt "
    select opt in "${options[@]}" "Quit" ; do
        if (( REPLY == 1 + ${#options[@]} )) ; then
            echo "Bye!"
            exit 2
        elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
            break
        else
            echo "Invalid option. Try another one."
        fi
    done
    COLUMNS=$oldcolumns
    r_initial=${opt}
};

check_for_repository() {
    _dir_original=$(pwd)
    if [ -f "flake.nix" ]; then
        _dir_flake=$(pwd)
    else
        while [ ! -f "${_dir_flake}flake.nix" ] ; do
                print_info "flake.nix not found! I need to work with in a repository with Nix Flakes"
                COLUMNS=12

                prompt="Where is your NixOS repository?"
                options=( "Local Filesystem" "Git Repository" )
                PS3="$prompt "
                select opt in "${options[@]}" "Quit" ; do
                    if (( REPLY == 1 + ${#options[@]} )) ; then
                        echo "Bye!"
                        exit 2
                    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
                        break
                    else
                        echo "Invalid option. Try another one."
                    fi
                done
                COLUMNS=$oldcolumns
                r_repository_location=${opt}

                case "${r_repository_location}" in
                    "Git Repository" )
                        counter=1
                        q_git_repository=" "
                        while [[ $q_git_repository = *" "* ]];  do
                            if [ $counter -gt 1 ] ; then print_error "Git Repositories cannot have spaces in them" ; fi ;
                            read -e -p "$(echo -e ${clg}** ${cdgy}Enter the location of your Git Repository:\ ${coff})" q_git_repository
                            (( counter+=1 ))
                        done

                        _dir_flake=$(mktemp -d)
                        print_info "Cloning Git repository to '${_dir_flake}'"
                        git clone ${q_git_repository} "${_dir_flake}"
                        git_clone_exit_code=$?

                    ;;
                    "Local Filesystem" )
                        counter=1
                        q_git_repository=" "
                        while [[ $q_git_repository = *" "* ]];  do
                            if [ $counter -gt 1 ] ; then print_error "Git Repositories path cannot have spaces in them" ; fi ;
                            read -e -p "$(echo -e ${clg}** ${cdgy}Enter the location of your on your filesystem:\ ${coff})" q_git_repository
                            (( counter+=1 ))
                        done

                        _dir_flake=${q_git_repository}/
                    ;;
                esac
        done
    fi
}

q_menu() {
     if [ "${os}" = "nixos" ] ; then
        option_upgrade=Upgrade_System
    fi
    COLUMNS=12
    prompt="What do you want to do?"
    options=( "Update Flake" $option_upgrade )
    PS3="$prompt "
    select opt in "${options[@]}" "Quit" ; do
        if (( REPLY == 1 + ${#options[@]} )) ; then
            echo "Bye!"
            exit 2
        elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
            break
        else
            echo "Invalid option. Try another one."
        fi
    done
    COLUMNS=$oldcolumns

    case "${opt}" in
        "Update Flake" )
            flake_tools update
        ;;
        "Upgrade_System" )
            if [ "${os}" = "nixos" ] ; then
                flake_tools upgrade
            else
                print_error "Can't upgrade a non NixOS system"
            fi
        ;;
    esac
}

flake_tools() {
    case "${1}" in
        "update" )
            print_info "Updating Nix Flake"
            sudo nix flake update ${_dir_flake}/ --extra-experimental-features "nix-command flakes"
        ;;
        "upgrade" )
            print_info "Upgrading System"
            sudo nixos-rebuild switch --flake "${_dir_flake}"/#$(hostname)
        ;;
    esac

}
check_dependencies
check_for_repository
q_menu
