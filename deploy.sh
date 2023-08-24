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
** NixOS Deployment - Revision ${SCRIPT_VERSION}
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

q_deploy() {
    COLUMNS=12
    prompt="Which host do you want to deploy?"
    options=( $(find ${_dir_flake}/hosts/* -maxdepth 0 -type d | rev | cut -d / -f 1 | rev | sed "/common/d" | xargs -0) )
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
    export deploy_host=${opt}

    # cat flake.nix | sed -e '/${deploy_host} =/,/};/!d' -e '/specialArgs = {/,/};/!d' | tail +2 | sed "/};/d"
}

generate_ssh_key() {
    _dir_remote_rootfs=$(mktemp -d)
    mkdir -p "${_dir_remote_rootfs}"/${feature_impermanence}/etc/ssh/
    ssh-keygen -q -N "" -t ed25519 -C "${deploy_host}" -f "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key
    mkdir -p hosts/"${deploy_host}"/secrets
    cp -R "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key.pub hosts/"${deploy_host}"/secrets/
}

generate_age_secrets() {
    mkdir -p "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/
    ssh-to-age -private-key -i "${_dir_remote_rootfs}"/etc/ssh/ssh_host_ed25519_key > "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    sudo chown root:root "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    sudo chmod 400 "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    export _age_key_pub=$(cat "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age )
    echo -n "${bgn}Updating Secrets{$boff}"
    cat <<EOF

    In this first release, we are doing manual edits to files. Copy this blurb to an editor for the time being..
    Copy this line and place it underneath the 'keys:' section

  - &host_${deploy_host} ${_age_key_pub}

    Next - make sure that under the creation rules that it says something like this:

    - path_regex: hosts/common/secrets/.*
    key_groups:
    - age:
      - *host_${deploy_host}
      - *host_host1
      - *host_host2
      - *host_host3
      - *user_$(whoami)
  - path_regex: users/secrets.yaml
    key_groups:
    - age:
      - *host_${deploy_host}
      - *host_host1
      - *host_host2
      - *host_host3
      - *user_$(whoami)

    Finally - Make sure there is a section for the host defined that looks similar to this:

  - path_regex: hosts/soy/secrets/.*
    key_groups:
    - age:
      - *host_${deploy_host}
      - *user_$(whoami)
EOF

    read -n 1 -s -r -p "Press any key to open the editor"
    EDITOR=${EDITOR:-"nano"}
    $EDITOR ${_dir_flake}/.sops.yaml

    cat <<EOF
    ** Adding example host secret

    Now, we're going to open a sample secret file. Delete everything in the file and replace it with the following line and save:

    ${deploy_host}: Example secret for ${deploy_host}

EOF
    read -n 1 -s -r -p "Press any key to open the secrets editor"
    sops ${_dir_flake}/hosts/${deploy_host}/secrets/secrets.yaml


    #yq -i '."keys" += "&host_'$(echo $deploy_host)' '$(echo $_age_key_pub)'"' .sops.playground.yaml
    #yq -i '.creation_rules[] | select(.path_regex=="hosts/common/secrets/.*") | ."key_groups" += [{"age": ["*host_'$(echo $deploy_host)'"]}] ' .sops.playground.yaml
    #yq -i '.creation_rules[] | select(.path_regex=="users/secrets.yaml") | ."key_groups" += [{"age": ["*host_'$(echo $deploy_host)'"]}] ' .sops.playground.yaml
}

q_disk() {
    COLUMNS=12
    prompt="Which Disk template do you want to deploy?"
    options=( $(find ${_dir_flake}/templates/disko/* -maxdepth 0 -type f | rev | cut -d / -f 1 | rev | sed "s|.nix||g" | xargs -0) )
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
    export deploy_disk=${opt}

    echo "DEPLOY DISK IS: ${deploy_disk}"
    ## Need to do something about this and ask for LUKS password
}

deploy_host() {
    counter=1
    remote_host_ip_address_tmp=256.256.256.256
    until ( valid_ip $remote_host_ip_address_tmp ) ; do
        if [ $counter -gt 1 ] ; then print_error "IP is bad, please reenter" ; fi ;
            read -e -p "$(echo -e ${clg}** ${cdgy}Remote Host IP Address: \ ${coff})" remote_host_ip_address_tmp
        (( counter+=1 ))
    done
    remote_host_ip_address=$remote_host_ip_address_tmp
    print_info "Commencing install to Host: ${deploy_host} (${remote_host_ip_address})"
    #nix run github:numtide/nixos-anywhere -- --no-reboot ${feature_luks} --extra-files ${_dir_remote_rootfs}" "${_dir_flake}"/#${deploy_host} root@${remote_host_ip_address}
}

check_dependencies
#check_for_repository
#q_deploy
#generate_ssh_key
#generate_age_key
#q_disk
#deploy_host
q_menu

# cat flake.nix | sed -e '/${deploy_host} =/,/};/!d' -e '/specialArgs = {/,/};/!d' | tail +2 | sed "/};/d"
