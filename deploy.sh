#!/usr/bin/env bash

SCRIPT_VERSION=0.0.1
LOG_LEVEL=NOTICE
SSH_PORT=${SSH_PORT:-"22"}
REMOTE_USER=${REMOTE_USER:-"$(whoami)"}

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
******************************************************************************************************************************
** NixOS Deployment - Revision ${SCRIPT_VERSION}
**
** - Based on a series of menus this tool will assist in deploying a new or existing NixOS Installation
** - This will install from either a NixOS ISO or an alternative operating system such as the OVH Rescue Image
** - Secrets Management using using SOPS
** - Basic Flake Management
**
** - Using Nix Flakes, this harnesses the power of 'disko' and 'nixos-anywhere' to perform remote installations or deployments
**
** - Prerequisites:
**     - A working nix installation, preferably a NixOS installation
**     - 'git', 'age', 'ssh-to-age', 'sops'
**
**
** - Usage:
**   '$(basename $0)'                      - Interative Mode (Default)
**   '$(basename $0)' --help               - Yer lookin at it
**   '$(basename $0)' --debug              - Shows Output of commands behind the scenes
**   '$(basename $0)' --changelog          - Shows this tools Changelog
**   '$(basename $0)' --version            - Shows this tools version
**   '$(basename $0)' --(arguments)        - Pass any arguments to alter default behaviour
**
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
    os=$(cat /etc/os-release |grep ^ID= | cut -d = -f 2)
    #set +e
    case "${1}" in
        git )
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
        ;;
        nix )
            if ! type "nix" > /dev/null 2>&1 ; then
                print_warn "[check_dependencies] nix not found, installing.."
                case $os in
                    "debian" )
                        debian_version=$(cat /etc/os-release |grep ^VERSION_ID= | cut -d = -f 2 | cut -d '"' -f 2)
                        case $debian_version in
                            *)
                                print_debug "[check_dependencies] Debian ${debian_version} detected"
                                silent sudo  sudo install -d -m755 -o "$(id -u)" -g "$(id -g)" /nix
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
        ;;
    esac
    #set -e
}

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
                r_repository_location=${opt}

                case "${r_repository_location}" in
                    "Git Repository" )
                        check_dependencies git
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

check_host_availability() {
    remote_ip_tmp=$(getent hosts ${deploy_host} | awk '{print $1}')
    if [ "$?" = 0 ]; then
        REMOTE_IP=${remote_ip_tmp}
    else
        print_warn "Couldn't resolve hostname, please enter in an IP Address"
        install_and_deploy_q_ipaddress
    fi
}

copy_ssh_key() {
    print_notice "Performing Check against SSH that you can log in"
    ssh-copy-id -p ${SSH_PORT} ${ssh_private_key_prefix} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP}
}

flake_tools() {
    check_dependencies nix
    case "${1}" in
        "edit" )
            $EDITOR "${_dir_flake}"/flake.nix
        ;;
        "update" )
            print_info "Updating Nix Flake"
            sudo nix flake update "${_dir_flake}"/ --extra-experimental-features "nix-command flakes"
        ;;
        "upgrade" )
            print_info "Upgrading System"
            sudo nixos-rebuild switch --flake "${_dir_flake}"/#"$(hostname)"
        ;;
    esac
}

menu_deploy() {
    if [ -f "${_dir_flake}"/hosts/"${deploy_host}"/secrets/secrets.yaml ] ; then
        option_secrets="(${cwh}S${cdgy}) Host secrets.yaml \n"
    fi

    printf "\033c"
    echo -e "${clm}"
    cat << EOF
-------------
| Deploy Menu |
-------------

Perform a new installation or update an existing installation remotely.

EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}N${cdgy}\) New Install for Host: ${deploy_host}\\n\(${cwh}E${cdgy}\) Update Existing Host: ${deploy_host} \\n\\n${cwh}CHANGE:\\n${cdgy}\(${cwh}S${cdgy}\) Regenerate SSH Keys for: ${deploy_host}\\n\(${cwh}A${cdgy}\) Regenerate AGE Secret Keys for ${deploy_host}\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_deploy
    case "${q_menu_deploy,,}" in
        "n" | "new" )
            install_q_disk
            task_generate_ssh_key
            task_generate_age_secrets
            menu_deploy
        ;;
        "e" | "existing" )
            task_update_host
            menu_deploy
        ;;
        "s" | "ssh" )
            task_generate_ssh_key
            menu_deploy
        ;;
        "a" | "age" )
            task_generate_age_secrets
            menu_deploy
        ;;
        "b" | "back" )
            menu_host
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Host${cdgy} - Change host"
            echo -e ""
            echo -e "${cwh}IP Address${cdgy} - Change IP address of remote host "
            echo -e ""
        ;;
        * )
            menu_deploy
        ;;

    esac
}

menu_flaketools() {
    if [ "${os}" = "nixos" ] ; then
        option_upgrade="(${cwh}S${cdgy}) Upgrade running NixOS system\\n"
        intro_upgrade="As this is a NixOS system, you can also use upgrade the running system from this menu."
    fi

    printf "\033c"
    echo -e "${clm}"
    cat << EOF
---------------
| Flake Tools |
---------------

Use this section to adjust configuration in your flake.nix file. You can then update its flake.lock file.
${intro_upgrade}
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\\n\(${cwh}E${cdgy}\) Edit flake.nix\\n\(${cwh}U${cdgy}\) Update flake.lock\\n${option_upgrade}\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to main menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_flaketools
    case "${q_menu_flaketools,,}" in
        "e" | "edit" )
            flake_tools edit
            menu_flaketools
        ;;
        "u" | "update" )
            flake_tools update
            menu_flaketools
        ;;
        "s" | "system" )
            if [ "${os}" = "nixos" ] ; then
                flake_tools upgrade
                menu_flaketools
            else
                print_error "Can't upgrade a non NixOS system"
                menu_flaketools
            fi
        ;;
        "b" | "back" )
            menu_startup
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Host${cdgy} - Change host"
            echo -e ""
            echo -e "${cwh}IP Address${cdgy} - Change IP address of remote host "
            echo -e ""
            menu_flaketools
        ;;
        * )
            menu_flaketools
        ;;
    esac
}

menu_host() {
    if [ -f "${_dir_flake}"/hosts/"${deploy_host}"/secrets/secrets.yaml ] ; then
        option_secrets="(${cwh}S${cdgy}) Host secrets.yaml \n"
    fi

    printf "\033c"
    echo -e "${clm}"
    cat << EOF
-------------
| Host Menu |
-------------

You can change your selected host configuration and IP Address here if you made a mistake.

You have the capabilities of editing the hosts configuration, the main repository flake, and the hosts secrets.
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cwh}CHANGE:${cdgy}\\n\\n\(${cwh}H${cdgy}\) Host: ${deploy_host}\\n\(${cwh}I${cdgy}\) IP Address: ${REMOTE_IP} \\n${cdgy}\\n\(${cwh}R${cdgy}\) SSH Options\\n\\n${cwh}DEPLOY:${cdgy}\\n\\n\(${cwh}D${cdgy}\) Deploy Configuration \\n\\n${cwh}EDIT:${cdgy}\\n\\n\(${cwh}E${cdgy}\) Host Configuration \\n\(${cwh}F${cdgy}\) Flake \\n${option_secrets}${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to main menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_host
    case "${q_menu_host,,}" in
        "d" | "deploy" )
            menu_deploy
        ;;
        "h" | "host" )
            install_and_deploy_q_host
            menu_host
            ;;
        "i" | "ip" )
            install_and_deploy_q_ipaddress
            check_host_availability
            menu_host
        ;;
        "e" | "edit" )
            $EDITOR "${_dir_flake}"/hosts/"${deploy_host}"/default.nix
            menu_host
        ;;
        "f" | "flake" )
            $EDITOR "${_dir_flake}"/flake.nix
            menu_host
        ;;
        "s" | "secrets" )
            sops "${_dir_flake}"/hosts/"${deploy_host}"/secrets/secrets.yaml
            menu_host
        ;;
        "r" | "ssh" )
            menu_ssh_options
        ;;
        "b" | "back" )
            menu_startup
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
        ;;
        "?" |  "help" )
            echo -e "${clm}"
            echo -e "${cwh}Host${cdgy} - Change host"
            echo -e ""
            echo -e "${cwh}IP Address${cdgy} - Change IP address of remote host "
            echo -e ""
        ;;
        * )
            menu_host
        ;;

    esac
}

menu_secrets() {
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
---------------------
| Secrets Additions |
---------------------

Edit Global SOPS secrets configuration here.
Rekey existing secrets after adding any new keys or configurations.

EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}E${cdgy}\) Edit .sops.yaml\\n\(${cwh}R${cdgy}\) Rekey all secrets\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to main menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_secrets
    case "${q_menu_secrets,,}" in
        "e" | "edit" )
            secret_tools edit
            menu_secrets
        ;;
        "r" | "rekey" )
            secret_tools rekey all
            menu_secrets
        ;;
        "b" | "back" )
            menu_startup
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Edit${cdgy} - Edits the .sops.yaml global secret configuration"
            echo -e ""
            echo -e "${cwh}Rekey${cdgy} - Rekeys all secrets from hosts, common, users"
            echo -e ""
        ;;
        * )
            menu_secrets
        ;;

    esac
}

menu_host_secrets() {
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
----------------------
| Secrets Management |
----------------------

In this first release, we are doing manual edits to files.

- Edit Global SOPS secrets configuration here.
- Edit Host Secrets
- Rekey existing secrets after adding any new keys or configurations.

EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}G${cdgy}\) Global secrets management\\n\(${cwh}H${cdgy}\) Host secrets management\\n\(${cwh}R${cdgy}\) Rekey all secrets\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_host_secrets
    case "${q_menu_host_secrets,,}" in
        "g" | "global" )
            menu_host_secrets_global
            menu_host_secrets_
        ;;
        "h" | "host" )
            menu_host_secrets_host
            menu_host_secrets_
        ;;
        "r" | "rekey" )
            secret_tools rekey all
            menu_host_secrets_
        ;;
        "b" | "back" )
            menu_host
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Global${cdgy} - Opens the menu detailing changes to global secrets"
            echo -e ""
            echo -e "${cwh}Hosts${cdgy} - Opens the menu detailing changes to host secrets"
            echo -e ""
            echo -e "${cwh}Rekey${cdgy} - Rekeys all secrets from hosts, common, users"
            echo -e ""
        ;;
        * )
            menu_host_secrets
        ;;
    esac
}

menu_host_secrets_global() {
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
---------------------
| Secrets Additions |
---------------------

    In this first release, we are doing manual edits to files.

    GLOBAL SECRETS
    You must add the following to the global file:

       - Copy this line and place it underneath the 'keys:' section
###

  - &host_${deploy_host} ${_age_key_pub}

###
       - Make sure that under the creation rules that it says something like this:

###
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
###

EOF

    echo -e "${coff}"
    read -p "$(echo -e \\n$\(${cwh}E${cdgy}\) Edit .sops.yaml\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host secrets menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_host_secrets_global
    case "${q_menu_host_secrets_global,,}" in
        "e" | "edit" )
            $EDITOR ${_dir_flake}/.sops.yaml
            menu_host_secrets_global
        ;;
        "b" | "back" )
            menu_host_secrets
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Edit${cdgy} - Edit the secrets file"
            echo -e ""
        ;;
        * )
            menu_host_secrets_global
        ;;
    esac
}

menu_host_secrets_host() {
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
--------------------------
| Host Secrets Additions |
--------------------------

    HOST SECRETS

    Create an example secret. Delete everything in the file and replace it with the following line:

${deploy_host}: Example secret for ${deploy_host}

EOF

    echo -e "${coff}"
    read -p "$(echo -e \\n$\(${cwh}E${cdgy}\) Edit .sops.yaml\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host secrets menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_secrets_global
    case "${q_menu_secrets_global,,}" in
        "e" | "edit" )
            sops ${_dir_flake}/hosts/${deploy_host}/secrets/secrets.yaml
            menu_host_secrets_host
        ;;
        "b" | "back" )
            menu_host_secrets
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Edit${cdgy} - Edit the secrets file"
            echo -e ""
        ;;
        * )
            menu_host_secrets_host
        ;;
    esac
}

menu_startup() {
    print_info "Starting NixOS Deployment Script at $(TZ=${TIMEZONE} date -d @${script_start_time} '+%Y-%m-%d %H:%M:%S')"

    printf "\033c"
    echo -e "${clm}"
    cat << EOF
--------------------------
| NiXOS Deployment ${SCRIPT_VERSION} |
--------------------------

** WARNING ** This script will eat your cat if you aren't careful.
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}D${cdgy}\) Deploy or Install \\n\(${cwh}F${cdgy}\) Flake Tools \\n\(${cwh}S${cdgy}\) Secrets Management \\n${cwh}${coff}\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_startup
    case "${q_menu_startup,,}" in
        "f" | "flake" )
            MODE=FLAKE
            check_dependencies git
            check_dependencies nix
            if [ -n "${1}" ] ; then
                case "${1}" in
                    update )
                        flake_tools update
                        return
                    ;;
                    upgrade )
                        flake_tools upgrade
                        return
                    ;;
                esac
            fi
            menu_flaketools
        ;;
        "d" | "deploy" )
            MODE=DEPLOY
            install_and_deploy_q_host
            check_host_availability
            menu_host
        ;;
        "s" | "secrets" )
            MODE=SECRETS
            if [ -n "${2}" ] ; then
                case "${2}" in
                    edit )
                        secret_tools edit
                        return
                    ;;
                    rekey )
                        if [ -n "${3}" ]; then
                            case "${3}" in
                                all ) secret_tools rekey all ;;
                                common ) secret_tools rekey common ;;
                                users ) secret_tools rekey users ;;
                                *) secret_tools rekey ${3} ;;
                            esac
                        else
                            secret_tools all
                            return
                        fi
                    ;;
                esac
            fi
            menu_secrets
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
            ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Deploy${cdgy} - Builds and deploys to a remote host based on existing configuration"
            echo -e ""
            echo -e "${cwh}Flake${cdgy} - Performs updates to the 'flake.nix' file and also allows to update running system."
            echo -e ""
            echo -e "${cwh}Secrets${cdgy} - Performs repository widew update to the SOPS secrets configuration."
            echo -e ""
        ;;
        * )
            menu_startup
        ;;
    esac
};

menu_ssh_options() {
    if [ -n "${SSH_PRIVATE_KEY}" ]; then
        text_private_key="          SSH Private Key: ${SSH_PRIVATE_KEY}"
    fi
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
---------------
| SSH Options |
---------------

    Using SSH Username: ${REMOTE_USER}
          SSH Port: ${SSH_PORT}
${text_private_key}
EOF

    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}K${cdgy}\) Use a specific Private Key\\n\(${cwh}U${cdgy}\) Change SSH Username\\n\(${cwh}P${cdgy}\) Change SSH Port${cwh}${coff}\\n\\n${cdgy}\(${cwh}C${cdgy}\) Copy SSH Key to ${deploy_host}\\n\\n${cdgy}\(${cwh}B${cdgy}\) Back to host menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_ssh_options
    case "${q_menu_ssh_options,,}" in
        "k" | "key" )
            deploy_q_sshkey
            menu_ssh_options
        ;;
        "u" | "user" )
            deploy_q_username
            menu_ssh_options
        ;;
        "p" | "port" )
            deploy_q_sshport
            menu_ssh_options
        ;;
        "c" | "copy" )
            copy_ssh_key
            menu_ssh_options
        ;;
         "b" | "back" )
            menu_host
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Edit${cdgy} - Edit the secrets file"
            echo -e ""
        ;;
        * )
            menu_host_secrets_host
        ;;
    esac
}

secret_tools() {
    case "${1}" in
        "edit" )
            $EDITOR "${_dir_flake}"/.sops.yaml
        ;;
        "rekey" )
            print_info "Rekeying secrets"
            secret_rekey "${2}"
        ;;
    esac
}

secret_rekey() {
    case "${1}" in
        all )
            for secret in "${_dir_flake}"/hosts/*/secrets/* ; do
                if ! [[ $(basename "${secret}") =~ ssh_host.* ]] ; then
                    sops updatekeys ${secret}
                fi
            done
        ;;
        common )
            for secret in "${_dir_flake}"/hosts/common/secrets/* ; do
                if ! [[ $(basename "${secret}") =~ ssh_host.* ]] ; then
                    sops updatekeys ${secret}
                fi
            done
        ;;
        users )
            sops updatekeys "${_dir_flake}"/users/secrets.yaml
        ;;
        * )
            for secret in "${_dir_flake}"/hosts/${1}/secrets/* ; do
                if ! [[ $(basename "${secret}") =~ ssh_host.* ]] ; then
                    sops updatekeys ${secret}
                fi
            done
        ;;
    esac
}

install_and_deploy_q_host() {
    COLUMNS=12
    prompt="Which host do you want to target?"
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

install_and_deploy_q_ipaddress() {
        counter=1
        _remote_ip_tmp=256.256.256.256
        until ( valid_ip $remote_ip_tmp ) ; do
            if [ $counter -gt 1 ] ; then print_error "IP is bad, please reenter" ; fi ;
                read -e -p "$(echo -e ${clg}** ${cdgy}Remote Host IP Address: \ ${coff})" remote_ip_tmp
            (( counter+=1 ))
        done
        REMOTE_IP=$remote_ip_tmp
}

deploy_q_username() {
    q_remote_username=" "
    while [[ $q_remote_username = *" "* ]];  do
        if [ $counter -gt 1 ] ; then print_error "Usernames cannot have spaces in them" ; fi ;
        read -e -p "$(echo -e ${clg}** ${cdgy}Enter your remote username:\ ${coff})" q_remote_username
        (( counter+=1 ))
    done
    counter=1
    REMOTE_USER="${q_remote_username}"
}

deploy_q_sshkey() {
    q_ssh_private_key" "
    while [[ $q_ssh_private_key = *" "* ]];  do
        if [ $counter -gt 1 ] ; then print_error "SSH Key paths cannot have spaces in them" ; fi ;
        read -e -p "$(echo -e ${clg}** ${cdgy}Enter the path and filename of your SSH Private key:\ ${coff})" q_ssh_private_key
        if [ ! -f "${q_ssh_private_key}" ] ; then print_error "Path and Filename for SSH Private Key not valid!" ; fi
        (( counter+=1 ))
    done
    counter=1
    SSH_PRIVATE_KEY="${q_ssh_private_key}"
}

deploy_q_sshport() {
    q_ssh_port=" "
    while [[ $q_ssh_port = *" "* ]];  do
        if [ $counter -gt 1 ] ; then print_error "SSH Port cannot have spaces in them" ; fi ;
        read -e -p "$(echo -e ${clg}** ${cdgy}Enter the port that the SSH server is listening on:\ ${coff})" q_ssh_port
        (( counter+=1 ))
    done
    counter=1
    SSH_PORT=${q_ssh_port}
}

task_generate_age_secrets() {
    mkdir -p "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/
    ssh-to-age -private-key -i "${_dir_remote_rootfs}"/etc/ssh/ssh_host_ed25519_key > "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    sudo chown root:root "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    sudo chmod 400 "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    export _age_key_pub=$(cat "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age )
    #yq -i '."keys" += "&host_'$(echo $deploy_host)' '$(echo $_age_key_pub)'"' .sops.playground.yaml
    #yq -i '.creation_rules[] | select(.path_regex=="hosts/common/secrets/.*") | ."key_groups" += [{"age": ["*host_'$(echo $deploy_host)'"]}] ' .sops.playground.yaml
    #yq -i '.creation_rules[] | select(.path_regex=="users/secrets.yaml") | ."key_groups" += [{"age": ["*host_'$(echo $deploy_host)'"]}] ' .sops.playground.yaml
}

task_generate_ssh_key() {
    _dir_remote_rootfs=$(mktemp -d)
    mkdir -p "${_dir_remote_rootfs}"/${feature_impermanence}/etc/ssh/
    ssh-keygen -q -N "" -t ed25519 -C "${deploy_host}" -f "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key
    mkdir -p hosts/"${deploy_host}"/secrets
    cp -R "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key.pub hosts/"${deploy_host}"/secrets/
}

install_q_disk() {
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

task_install_host() {
    print_info "Commencing install to Host: ${deploy_host} (${remote_host_ip_address})"
    #nix run github:numtide/nixos-anywhere -- \
    #                                            --ssh-port ${SSH_PORT} ${ssh_private_key_prefix} \
    #                                            --no-reboot \
    #                                            ${feature_luks} --extra-files ${_dir_remote_rootfs}" \
    #                                            --flake "${_dir_flake}"/#${deploy_host} \
    #                                            root@${remote_host_ip_address}
}

task_update_host() {
    if [ -n "${SSH_PRIVATE_KEY}" ]; then
        ssh_private_key_prefix="-i ${SSH_PRIVATE_KEY}"
        ssh_private_key_text="via SSH Private key located at ${SSH_PRIVATE_KEY}"
    fi

    printf "\033c"
    echo -e "${clm}"
    cat << EOF
---------------
| Update Host |
---------------

Updating host ${deploy_host} via ssh://${REMOTE_USER}@${REMOTE_IP} ${ssh_private_key_text}
Confirm you wish to start the deployment, or change the username or IP. Also, use a custom Private Key.
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}Y${cdgy}\) Confirm Update \\n\\n\(${cwh}S${cdgy}\) SSH Options \\n\(${cwh}B${cdgy}\) Back to host deploy menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_task_update
    case "${q_task_update,,}" in
        "y" | "yes" )
            print_info "Commencing update to remote host"
            NIX_SSHOPTS="-t -p ${SSH_PORT} ${ssh_private_key_prefix} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" nixos-rebuild switch --flake "${_dir_flake}"/#${deploy_host} --use-remote-sudo --target-host ${REMOTE_USER}@${REMOTE_IP} --use-remote-sudo
            read -n 1 -s -r -p "** Press any key to continue **"
            task_update_host
        ;;
        "s" | "ssh" )
            menu_ssh_options
        ;;
        "b" | "back" )
            menu_deploy
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            exit 1
            ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e ""
        ;;
        * )
            menu_startup
        ;;
    esac
}

################
check_for_repository
case "${1,,}" in
    deploy )
        MODE=DEPLOY
    ;;
    flake )
        MODE=FLAKE
    ;;
    install )
        MODE=INSTALL
    ;;
esac

if [ -z "${MODE}" ] ; then menu_startup ; fi

case "${MODE,,}" in
    deploy )
        install_and_deploy_q_host
        install_and_deploy_q_ipaddress
        menu_host
    ;;
    flake )
        check_dependencies git
        check_dependencies nix
        if [ -n "${2}" ] ; then
            case "${2}" in
                update )
                    flake_tools update
                    exit
                ;;
                upgrade )
                    flake_tools upgrade
                    exit
                ;;
            esac
        fi
        menu_flaketools
    ;;
    secrets )
        if [ -n "${2}" ] ; then
            case "${2}" in
                edit )
                    secret_tools edit
                    exit
                ;;
                rekey )
                    if [ -n "${3}" ]; then
                        case "${3}" in
                            all ) secret_tools rekey all ;;
                            common ) secret_tools rekey common ;;
                            users ) secret_tools rekey users ;;
                            *) secret_tools rekey ${3} ;;
                        esac
                    else
                        secret_tools all
                        exit
                    fi
                ;;
            esac
        fi
        menu_secrets
    ;;
esac
