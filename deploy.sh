#!/usr/bin/env bash

SCRIPT_VERSION=1.6.1

INSTALL_BUILD_LOCAL=${INSTALL_BUILD_LOCAL:-"TRUE"}
INSTALL_DEBUG=${INSTALL_DEBUG:-"FALSE"}
INSTALL_REBOOT=${INSTALL_REBOOT:-"FALSE"}
LOG_LEVEL=NOTICE
REMOTE_USER=${REMOTE_USER:-"$(whoami)"}
SECRET_USER="dave"
SECRET_HOST="beef"
SSH_PORT=${SSH_PORT:-"22"}

if [ -f ".deploy.env" ] ; then source .deploy.env ; fi

case "${1}" in
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
**   '$(basename "$0")'                      - Interative Mode (Default)
**   '$(basename "$0")' --help               - Yer lookin at it
**   '$(basename "$0")' --debug              - Shows Output of commands behind the scenes
**   '$(basename "$0")' --changelog          - Shows this tools Changelog
**   '$(basename "$0")' --version            - Shows this tools version
**   '$(basename "$0")' --(arguments)        - Pass any arguments to alter default behaviour
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
    ip=$(getent ahosts "${1}" | grep STREAM | sed "/:/d" | awk '{print $1}')
    stat=1
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

wait_for_keypress() {
    read -n 1 -s -r -p "** Press any key to continue **"
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
                select opt in "${options[@]}" "Back" ; do
                    if (( REPLY == 1 + ${#options[@]} )) ; then
                        break
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
    getent ahosts ${1} | grep STREAM | sed "/:/d" | awk '{print $1}' > /dev/null
    host_available_exit=$?
    remote_ip_tmp=$(getent ahosts ${1} | grep STREAM | sed "/:/d" | awk '{print $1}')
    if [ "${host_available_exit}" = 0 ]; then
        REMOTE_IP=${remote_ip_tmp}
    else
        print_warn "Couldn't resolve hostname, please enter in a new hostname or ip address"
        task_set_ip_address
    fi
}

cleanup() {
   if [ -d "${_dir_remote_rootfs}" ]; then rm -rf "${_dir_remote_rootfs}"; fi
   if [ -f "${_template_chooser}" ]; then rm -rf "${_template_chooser}"; fi
   if [ -f "${luks_key}" ]; then rm -rf "${luks_key}"; fi
}

ctrl_c() {
    cleanup
    exit
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

menu_diskconfig() {
    if var_true "${disk_encryption}"; then
        m_deploy_password="${cdgy}(${cwh}P${cdgy}) Update Encryption Password\\n"
    fi

    printf "\033c"
    echo -e "${clm}"
    cat << EOF
---------------------------
| Disk Configuration Menu |
---------------------------

You can change settings related to your disk configuration for new installs here.

You also have the capabilities of editing the hosts disk configuration
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cwh}CHANGE:${cdgy}\\n\\n\(${cwh}D${cdgy}\) Disk Template: ${deploy_disk_template}\\n${m_deploy_password}\(${cwh}S${cdgy}\) Swap Size \\n\\n${cwh}EDIT:${cdgy}\\n\\n\(${cwh}E${cdgy}\) Disk Template \\n${cdgy}\(${cwh}B${cdgy}\) Back to deploy menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_host
    case "${q_menu_host,,}" in
        "d" | "disk" )
            task_q_select_disktemplate
            if [ -z "${PASSWORD_ENCRYPTION}" ] ; then task_generate_encryption_password ; fi
            menu_diskconfig
            ;;
        "e" | "edit" )
            if [ -f "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix ] ; then
                $EDITOR "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix
            else
                print_error "Can't edit Disk Template as it hasn't been selected yet"
                sleep 5
            fi
            menu_diskconfig
        ;;
        "p" | "password" )
            task_generate_encryption_password
            menu_diskconfig
        ;;
        "s" | "swap" )
            task_update_swap_size
            menu_diskconfig
        ;;
        "b" | "back" )
            menu_deploy
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
        ;;
        "?" |  "help" )
            echo -e "${clm}"
            echo -e ""
        ;;
        * )
            menu_host
        ;;

    esac
}

menu_execute_options() {
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
---------------------------
| Hosts Execution Options |
---------------------------

Build configuration locally and send remotely, or build on remote host
Reboot remote host after install
Set Allow more debug verbosity
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}L${cdgy}\) Local Build: ${INSTALL_BUILD_LOCAL^}\\n\(${cwh}R${cdgy}\) Reboot after installation: ${INSTALL_REBOOT^}\\n\(${cwh}D${cdgy}\) Debug Installation: ${INSTALL_DEBUG^}\\n\\n\(${cwh}B${cdgy}\) Back to main menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_hostexecution
    case "${q_menu_hostexecution,,}" in
        "l" | "build" )
            if var_true "${INSTALL_BUILD_LOCAL}" ; then
                INSTALL_BUILD_LOCAL=FALSE
            else
                INSTALL_BUILD_LOCAL=TRUE
            fi
            menu_execute_options
        ;;
        "r" | "reboot" )
            if var_true "${INSTALL_REBOOT}" ; then
                INSTALL_REBOOT=FALSE
            else
                INSTALL_REBOOT=TRUE
            fi
            menu_execute_options
        ;;
        "d" | "debug" )
            if var_true "${INSTALL_DEBUG}" ; then
                INSTALL_DEBUG=FALSE
            else
                INSTALL_DEBUG=TRUE
            fi
            menu_execute_options
            ;;
        "b" | "back" )
            menu_host
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
        ;;
        "?" |  "help" )
            echo -e "${clm}"
            echo -e ""
        ;;
        * )
            menu_host
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
            cleanup
        ;;
        "?" | "help" )
            echo -e "${clm}"
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

    if [ "${REMOTE_IP}" != "" ]; then
        menu_host_option_deploy="\\n${cwh}DEPLOY:${cdgy}\\n\\n${cdgy}(${cwh}N${cdgy}) New Installation\\n(${cwh}U${cdgy}) Update Existing Installation\\n"
    fi

    printf "\033c"
    echo -e "${clm}"
    cat << EOF
-------------
| Host Menu |
-------------

Fill in details of the IP Addresss - It may be auto populated if found in DNS, otherwise enter Hostname or IP
Change any settings for SSH, specifically the username, and make sure that you can support passwordless logins to the host in question.

Once ready, deploy the configuration.

You can also update the hosts configuration and you'll need to ensure that secrets have been generated.
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}Host: ${cwh}${deploy_host}${cdgy}\\n\\n${cwh}CHANGE:${cdgy}\\n\\n\(${cwh}I${cdgy}\) IP Address: ${cwh}${REMOTE_IP}${cdgy}\\n${cdgy}\(${cwh}R${cdgy}\) SSH Options\\n${menu_host_option_deploy}\\n${cwh}EDIT:${cdgy}\\n\\n\(${cwh}E${cdgy}\) Host Configuration \\n\(${cwh}F${cdgy}\) Flake \\n${option_secrets}${cwh}${coff}\\n${cdgy}\(${cwh}S${cdgy}\) Host Secrets\\n${cdgy}\(${cwh}X${cdgy}\) Remote Options\\n${cdgy}\(${cwh}B${cdgy}\) Back to host management menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_host
    case "${q_menu_host,,}" in
        "i" | "ip" )
            unset REMOTE_IP
            task_set_ip_address
            check_host_availability "${REMOTE_IP}"
            menu_host
        ;;
        "n" | "new" )
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
--------------------
| New Installation |
--------------------

Before the installation the following needs to occur:

  - Setup Disk Drives
  - Set Encryption passwords if necessary
  - Ask for Network Card MAC Address if necessary
  - Generate SSH Key
  - Generate SOPS Secrets
  - Generate sample host secret

EOF
            task_parse_disk_config
            if [ -z "${DISK_SWAP_SIZE_GB}" ] ; then task_update_swap_size; fi
            if [ -z "${PASSWORD_ENCRYPTION}" ] ; then task_generate_encryption_password ; fi
            if var_nottrue "${task_generate_ssh_key_new}" ; then task_generate_ssh_key new ;fi
            if var_nottrue "${task_generate_age_secrets_new}" ; then task_generate_age_secrets new ; fi
            if var_nottrue "${task_generate_sops_configuration_new}" ; then task_generate_sops_configuration new ; fi
            if var_nottrue "${task_generate_host_secrets_new}" ; then task_generate_host_secrets new; fi
            secret_rekey_silent=true
            secret_tools rekey all
            secret_rekey_silent=false
            task_install_host
            menu_host
        ;;
        "u" | "update" )
            task_update_host
            menu_host
        ;;
        "d" | "disk" )
            menu_diskconfig
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
            menu_host_secrets
        ;;
        "r" | "ssh" )
            menu_ssh_options
        ;;
        "x" | "xecute options" )
            menu_execute_options
        ;;
        "b" | "back" )
            menu_host_management
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
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

menu_host_management() {
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
-------------------------
| Hosts Management Menu |
-------------------------

Choose a host to perform work on
Create a new template for a new never before installed host
Delete a host from filesystem
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}H${cdgy}\) Choose Host to configure\\n\\n\(${cwh}C${cdgy}\) Create new host configuration\\n\(${cwh}D${cdgy}\) Delete host configuration\\n\\n\(${cwh}F${cdgy}\) Edit Flake \\n\(${cwh}B${cdgy}\) Back to main menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_hostmanagement
    case "${q_menu_hostmanagement,,}" in
        "c" | "create" )
            task_hostmanagement_create
            menu_host
        ;;
        "d" | "delete" )
            task_hostmanagement_delete
            menu_host_management
        ;;
        "h" | "host" )
            menu_host_management_select_host
            menu_host
            ;;
        "f" | "flake" )
            $EDITOR "${_dir_flake}"/flake.nix
            menu_host_management
        ;;
        "b" | "back" )
            menu_startup
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
        ;;
        "?" |  "help" )
            echo -e "${clm}"
            echo -e ""
        ;;
        * )
            menu_host
        ;;

    esac
}

menu_host_management_select_host() {
    COLUMNS=12
    echo -e "${cwh}"
    prompt="Which host do you want to target?"
    options=( $(find ${_dir_flake}/hosts/* -maxdepth 0 -type d | rev | cut -d / -f 1 | rev | sed "/common/d" | xargs -0) )
    PS3="$prompt "
    select opt in "${options[@]}" "Back" ; do
        if (( REPLY == 1 + ${#options[@]} )) ; then
            menu_host
        elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
            break
        else
            echo "Invalid option. Try another one."
        fi
    done
    echo -e "${cdgy}"
    COLUMNS=$oldcolumns
    export deploy_host=${opt}

    if grep -q "hostname = \".*\"" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix ; then
        hname=$(grep "hostname = \".*\"" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix | cut -d '"' -f 2)

        if grep -q "domainname = \".*\"" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix ; then
            dname=".$(grep "domainname = \".*\"" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix | cut -d '"' -f 2)"
        elif grep -q "domainname = .*\".*\"" "${_dir_flake}"/hosts/common/default.nix ; then
            dname=".$(grep "domainname = .*\".*\"" "${_dir_flake}"/hosts/common/default.nix | cut -d '"' -f 2)"
        fi

        if [ -n "${hname}" ]; then check_host_availability ${hname}${dname}; fi
    fi
}

menu_host_secrets() {
    if [ -f "${_dir_flake}"/hosts/"${deploy_host}"/secrets/secrets.yaml ]; then
        menu_host_secrets_option_host_secrets="${cdgy}(${cwh}H${cdgy}) Host secrets management\\n"
    fi

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
    read -p "$(echo -e ${menu_host_secrets_option_host_secrets}${cdgy}\(${cwh}G${cdgy}\) Global secrets management\\n\(${cwh}R${cdgy}\) Rekey all secrets\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_host_secrets
    case "${q_menu_host_secrets,,}" in
        "g" | "global" )
            menu_host_secrets_global
            menu_host_secrets
        ;;
        "h" | "host" )
            if [ -f "${_dir_flake}"/hosts/"${deploy_host}"/secrets/secrets.yaml ]; then
                menu_host_secrets_host
            fi
            menu_host_secrets
        ;;
        "r" | "rekey" )
            secret_tools rekey all
            menu_host_secrets
        ;;
        "b" | "back" )
            menu_host
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
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

    Global configuration is required to use secrets.
    When you choose a new installation moficiations are performed to the .sops.yaml file.
    If you do not see entries related to the host, choose to apply the configuration - Only do this once!

    These entries must be in the .sops.yaml file be done otherwise you won't be able to login!
    Type 'help' to manually add the entries.

EOF

    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}A${cdgy}\) Apply auto modifications to .sops.yaml\\n\(${cwh}E${cdgy}\) Edit .sops.yaml\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host secrets menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_host_secrets_global
    case "${q_menu_host_secrets_global,,}" in
        "a" | "apply" )
            task_generate_sops_configuration
        ;;
        "e" | "edit" )
            $EDITOR "${_dir_flake}"/.sops.yaml
            menu_host_secrets_global
        ;;
        "b" | "back" )
            menu_host_secrets
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e "${cwh}Edit${cdgy} - Edit the secrets file"
            echo -e ""
            cat <<EOF
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

    Before you can do anything you'll need to crete an example secret.
    Create an example secret. Delete everything in the file and replace it with the following line:

${deploy_host}: Example secret for ${deploy_host}

    You can also add other secrets but the secret with starting with ${deploy_host} must exist.

EOF

    echo -e "${coff}"
    read -p "$(echo -e \\n${cdgy}\(${cwh}E${cdgy}\) Edit ${deploy_host}\/secrets\/secrets.yaml\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host secrets menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_secrets_host
    case "${q_menu_secrets_host,,}" in
        "e" | "edit" )
            task_generate_host_secrets
            menu_host_secrets_host
        ;;
        "b" | "back" )
            menu_host_secrets
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
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

menu_install_host() {
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
----------------
| Install Host |
----------------

Updating host ${deploy_host} via ssh://${REMOTE_USER}@${REMOTE_IP} ${ssh_private_key_text}
Confirm you wish to start the deployment, or change the username or IP. Also, use a custom Private Key.
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}Y${cdgy}\) Confirm Update \\n\\n\(${cwh}S${cdgy}\) SSH Options \\n\(${cwh}B${cdgy}\) Back to host deploy menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_task_install
    case "${q_menu_task_install,,}" in
        "y" | "yes" )
            task_install_host
            menu_install_host
        ;;
        "s" | "ssh" )
            menu_ssh_options
        ;;
        "b" | "back" )
            menu_deploy
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
            ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e ""
        ;;
        * )
            menu_install_host
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

Edit Global SOPS configuration here.
Edit hosts/common/secrets/secrets.yaml.
Rekey existing secrets after adding any new keys or configurations.

EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}E${cdgy}\) Edit .sops.yaml\\n\(${cwh}R${cdgy}\) Rekey all secrets\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to main menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_secrets
    case "${q_menu_secrets,,}" in
        "e" | "edit" )
            secret_tools edit
            menu_secrets
        ;;
        "c" | "common" )
            secret_tools common
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
            cleanup
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

menu_ssh_options() {
    if [ -n "${SSH_PRIVATE_KEY}" ]; then
        text_private_key="          SSH Private Key: ${SSH_PRIVATE_KEY}"
    fi

    if [ "${REMOTE_IP}" != "" ]; then
        menu_ssh_options_copy_key="\\n${cdgy}(${cwh}C${cdgy}) Copy SSH Key to ${deploy_host}\\n"
        menu_ssh_options_connect_to_host="\\n(${cwh}S${cdgy}) Connect to Host\\n"
        text_ssh_options_set_ip="Set IP Address to copy public key to host"
        text_ssh_options_connect_to_host="SSH to the host"
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

${text_ssh_options_set_ip}
${text_ssh_options_connect_to_host}
EOF

    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}K${cdgy}\) Use a specific Private Key\\n\(${cwh}U${cdgy}\) Change SSH Username\\n\(${cwh}P${cdgy}\) Change SSH Port${cwh}${coff}\\n${menu_ssh_options_copy_key}${menu_ssh_options_connect_to_host}${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_ssh_options
    case "${q_menu_ssh_options,,}" in
        "k" | "key" )
            menu_ssh_options_q_sshkey
            menu_ssh_options
        ;;
        "u" | "user" )
            menu_ssh_options_q_username
            menu_ssh_options
        ;;
        "p" | "port" )
            menu_ssh_options_q_port
            menu_ssh_options
        ;;
        "c" | "copy" )
            task_copy_ssh_key
            menu_ssh_options
        ;;
        "s" | "ssh" )
            task_ssh_to_host
        ;;
         "b" | "back" )
            menu_host
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
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

menu_ssh_options_q_port() {
    local counter=0
    q_ssh_port=" "
    while [[ $q_ssh_port = *" "* ]];  do
        if [ $counter -gt 1 ] ; then print_error "SSH Port cannot have spaces in them" ; fi ;
        read -e -p "$(echo -e ${clg}** ${cdgy}Enter the port that the SSH server is listening on:\ ${coff})" q_ssh_port
        (( counter+=1 ))
    done
    counter=1
    SSH_PORT=${q_ssh_port}
}

menu_ssh_options_q_sshkey() {
    local counter=0
    q_ssh_private_key=" "
    while [[ $q_ssh_private_key = *" "* ]];  do
        if [ $counter -gt 1 ] ; then print_error "SSH Key paths cannot have spaces in them" ; fi ;
        read -e -p "$(echo -e ${clg}** ${cdgy}Enter the path and filename of your SSH Private key:\ ${coff})" q_ssh_private_key
        if [ ! -f "${q_ssh_private_key}" ] ; then print_error "Path and Filename for SSH Private Key not valid!" ; fi
        (( counter+=1 ))
    done
    counter=1
    SSH_PRIVATE_KEY="${q_ssh_private_key}"
}

menu_ssh_options_q_username() {
    q_remote_username=" "
    while [[ $q_remote_username = *" "* ]];  do
        if [ $counter -gt 1 ] ; then print_error "Usernames cannot have spaces in them" ; fi ;
        read -e -p "$(echo -e ${clg}** ${cdgy}Enter your remote username:\ ${coff})" q_remote_username
        (( counter+=1 ))
    done
    counter=1
    REMOTE_USER="${q_remote_username}"
}

menu_startup() {
    if [ -n "${deploy_host}" ]; then
        _menu_startup_deploy="${cdgy}(${cwh}D${cdgy}) Deploy or Install \\n"
    fi

    print_info "Starting NixOS Deployment Script at $(TZ=${TIMEZONE} date -d @${script_start_time} '+%Y-%m-%d %H:%M:%S')"

    printf "\033c"
    echo -e "${clm}"
    cat << EOF
--------------------------
| NiXOS Deployment ${SCRIPT_VERSION} |
--------------------------

Start by selecting a Host via the Host Management Menu
Move to the Deploy Menu to perform a new install or an upgrade of host

** WARNING ** This script will eat your cat if you aren't careful.
EOF
    echo -e "${coff}"
    read -p "$(echo -e ${cdgy}\(${cwh}H${cdgy}\) Host Management\\n${_menu_startup_deploy}\(${cwh}F${cdgy}\) Flake Tools \\n\(${cwh}S${cdgy}\) Secrets Management \\n${cwh}${coff}\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_startup
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
            if [ -n "${deploy_host}" ]; then
                menu_host
            fi
            menu_startup
        ;;
        "h" | "host" )
            menu_host_management
            menu_startup
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
            cleanup
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

menu_update_host() {
    if [ -n "${SSH_PRIVATE_KEY}" ]; then
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
    read -p "$(echo -e ${cdgy}\(${cwh}Y${cdgy}\) Confirm Update \\n\\n\(${cwh}S${cdgy}\) SSH Options \\n\(${cwh}B${cdgy}\) Back to host deploy menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_task_update
    case "${q_menu_task_update,,}" in
        "y" | "yes" )
            task_update_host
            menu_update_host
        ;;
        "s" | "ssh" )
            menu_ssh_options
        ;;
        "b" | "back" )
            menu_deploy
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
            ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e ""
        ;;
        * )
            menu_update_host
        ;;
    esac
}

secret_tools() {
    case "${1}" in
        "common" )
            sops "${_dir_flake}"/hosts/common/secrets/secrets.yaml
        ;;
        "edit" )
            $EDITOR "${_dir_flake}"/.sops.yaml
        ;;
        "rekey" )
            task_secret_rekey "${2}"
        ;;
    esac
}

task_copy_ssh_key() {
    print_notice "Performing Check against SSH that you can log in"
    if [ -n "${SSH_PRIVATE_KEY}" ]; then
        task_copy_ssh_key_ssh_private_key="-i ${SSH_PRIVATE_KEY}"
    fi
    ssh-copy-id -p ${SSH_PORT} ${task_copy_ssh_key_ssh_private_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP}
    wait_for_keypress
}

task_hostmanagement_q_role() {
    cat << EOF
-----------------
| Host Creation |
-----------------

    A series of questions will be asked in order to create your new host based on templates.

    For role:
      - Desktop will install a GUI environment with specific desktop optimizations
      - Laptop is similar to the Desktop role yet includes power management optimizations
      - Kiosk is a specialized GUI environment meant for displaying content from a GUI application on a display
      - Minimal is a bare bones environment with minimal customizations and tools useful for very low memory environments
      - Server assumes zero GUI and assumes encryption, impermanence, and RAID
      - VM is similar to Desktop yet has specific virtualization optimizations

EOF

    echo -e "${coff}"

    read -p "$(echo -e What is the role of this host?\\n${cdgy}\(${cwh}S${cdgy}\) Server\\n\(${cwh}D${cdgy}\) Desktop\\n\(${cwh}L${cdgy}\) Laptop\\n\(${cwh}K${cdgy}\) Kiosk\\n\(${cwh}M${cdgy}\) Minimal\\n\(${cwh}V${cdgy}\) Virtual Machine\\n${cwh}${coff}\\n${cdgy}\(${cwh}B${cdgy}\) Back to host deploy menu\\n\\n${clg}** ${cdgy}What do you want to do\? : \  )" q_menu_hostaddition_role
    case "${q_menu_hostaddition_role,,}" in
        "d" | "desktop" )
            template_role="server"
            task_hostmanagement_q_impermanence
            task_hostmanagement_q_encryption
            task_hostmanagement_q_raid
        ;;
        "l" | "laptop" )
            template_role="laptop"
            task_hostmanagement_q_impermanence
            task_hostmanagement_q_encryption
        ;;
        "k" | "kiosk" )
            template_role="kiosk"
        ;;
        "m" | "minimal" )
            template_role="minimal"
        ;;
        "s" | "server" )
            template_role="server"
            task_hostmanagement_q_impermanence
            task_hostmanagement_q_encryption
            task_hostmanagement_q_raid
            task_hostmanagement_q_networking
        ;;
        "v" | "vm" )
            template_role="vm"
            task_hostmanagement_q_impermanence
            task_hostmanagement_q_networking
        ;;
        "b" | "back" )
            menu_host_management
        ;;
        "q" | "exit" )
            print_info "Quitting Script"
            cleanup
        ;;
        "?" | "help" )
            echo -e "${clm}"
            echo -e ""
            echo -e ""
        ;;
        * )
            menu_host_secrets_host
        ;;
    esac
}

task_hostmanagement_q_encryption() {
    while true; do
        read -p "$(echo -e ${clg}** ${cdgy}Enable Full Disk Encryption? \(${cwh}Y${cdgy}\) Yes \(default\) \| \(${cwh}N${cdgy}\) No  : ${cwh}${coff}) " q_encryption
        case "${q_encryption,,}" in
            "y" | "yes" | "" )
                _template_encryption=true
                break
            ;;
            "n" | "no" )
                _template_encryption=false
                break
            ;;
            "b" | "back" )
                menu_host_management
            ;;
            "q" | "exit" )
                print_info "Quitting Script"
                cleanup
            ;;
            "?" | "h" | "help" )
                echo -e "${clm}"
                echo -e "${cwh}Yes${cdgy} - Encrypt your disks from outside parties with a passcode"
                echo -e ""
                echo -e "${cwh}No${cdgy} - Do nothing"
                echo -e ""
            ;;
        esac
    done
}

task_hostmanagement_q_impermanence() {
    while true; do
        read -p "$(echo -e ${clg}** ${cdgy}Enable Impermanence? \(${cwh}Y${cdgy}\) Yes \(default\) \| \(${cwh}N${cdgy}\) No  : ${cwh}${coff}) " q_impermanence
        case "${q_impermanence,,}" in
            "y" | "yes" | "" )
                _template_impermanence=true
                break
            ;;
            "n" | "no" )
                _template_impermanence=false
                break
            ;;
            "b" | "back" )
                menu_host_management
            ;;
            "q" | "exit" )
                print_info "Quitting Script"
                cleanup
            ;;
            "?" | "h" | "help" )
                echo -e "${clm}"
                echo -e "${cwh}Yes${cdgy} - Start with a fresh root filesystem each startup"
                echo -e ""
                echo -e "${cwh}No${cdgy} - Do nothing"
                echo -e ""
            ;;
        esac
    done
}

task_hostmanagement_q_networking() {
    while true; do
        read -p "$(echo -e ${clg}** ${cdgy}Does this system have a wired network card\? \(${cwh}Y${cdgy}\) Yes \(default\) \| \(${cwh}N${cdgy}\) No  : ${cwh}${coff}) " q_wirednetworking
        case "${q_wirednetworking,,}" in
            "y" | "yes" | "" )
                _template_ip_wired=true
                while true; do
                    read -p "$(echo -e ${clg}** ${cdgy}Network IP Type: \? \(${cwh}S${cdgy}\) Static \(default\) \| \(${cwh}D${cdgy}\) DHCP : ${cwh})" q_network_ip_public_type
                    case "${q_network_ip_public_type,,}" in
                        "s" | "static" | "" )
                            _template_ip_type="static"
                            counter=1
                            network_ip_public_address_tmp=256.256.256.256
                            until ( valid_ip $network_ip_public_address_tmp ) ; do
                                if [ $counter -gt 1 ] ; then print_error "IP is bad, please reenter" ; fi ;
                                    read -e -i "$_template_network_ip" -p "$(echo -e ${clg}** ${cdgy}Public Network IP Address: \ ${coff})" network_ip_public_address_tmp
                                (( counter+=1 ))
                            done

                            _template_network_ip=${network_ip_public_address_tmp}
                            read -e -i "$_template_network_subnet" -p "$(echo -e ${clg}** ${cdgy}Network IP Subnet Mask \(eg 24\): \ ${coff})" _template_network_subnet

                            counter=1

                            network_ip_public_gateway_tmp=256.256.256.256
                            until ( valid_ip $network_ip_public_gateway_tmp ) ; do
                                if [ $counter -gt 1 ] ; then print_error "IP is bad, please reenter" ; fi ;
                                    read -e -i "$_template_network_gateway" -p "$(echo -e ${clg}** ${cdgy}Network IP Gateway: \ ${coff})" network_ip_public_gateway_tmp
                                (( counter+=1 ))
                            done
                            _template_network_gateway=${network_ip_public_gateway_tmp}
                            break
                            if [ -z "${_template_network_mac}" ]; then
                                read -e -i "$_template_network_mac" -p "$(echo -e ${clg}** ${cdgy}Network MAC Address \(eg 00:01:02:03:04:05\): \ ${coff})" _template_network_mac
                            fi
                        ;;
                        "d" | "dhcp" | "dynamic" )
                            _template_ip_type="dynamic"
                            if [ -z "${_template_network_mac}" ]; then
                                read -e -i "$_template_network_mac" -p "$(echo -e ${clg}** ${cdgy}Network MAC Address \(eg 00:01:02:03:04:05\): \ ${coff})" _template_network_mac
                            fi
                            break
                        ;;
                        "q" | "exit" )
                            print_info "Quitting Script"
                            cleanup
                        ;;
                        "?" | "h" | "help" )
                            echo -e "${clm}"
                            echo -e "${cwh}Static${cdgy} - Enter all the details in regarding your IP Address, Netmask, Gateway"
                            echo -e ""
                            echo -e "${cwh}DHCP${cdgy} - Let your Network Provider decide."
                        ;;
                        *)
                            echo -e "${bdr}ERROR:${boff} ${clm}Invalid Input - Please Try again${coff}"
                        ;;
                    esac
                done
                break
            ;;
            "n" | "no" )
                break
            ;;
            "b" | "back" )
                menu_host_management
            ;;
            "q" | "exit" )
                print_info "Quitting Script"
                cleanup
            ;;
            "?" | "h" | "help" )
                echo -e "${clm}"
                echo -e "${cwh}Yes${cdgy} - You want to configure your wired network card"
                echo -e ""
                echo -e "${cwh}No${cdgy} - Do nothing"
                echo -e ""
            ;;
        esac
    done
}

task_hostmanagement_q_raid() {
    while true; do
        read -p "$(echo -e ${clg}** ${cdgy}Do you have a RAID Array? \(${cwh}Y${cdgy}\) Yes \| \(${cwh}N${cdgy}\) No \(default\) : ${cwh}${coff}) " q_raid
        case "${q_raid,,}" in
            "y" | "yes" )
                _template_raid=true
                break
            ;;
            "n" | "no" | "" )
                _template_raid=false
                break
            ;;
            "b" | "back" )
                menu_host_management
            ;;
            "q" | "exit" )
                print_info "Quitting Script"
                cleanup
            ;;
            "?" | "h" | "help" )
                echo -e "${clm}"
                echo -e "${cwh}Yes${cdgy} - Use some sort of Redundant Array of Inexpensive disks"
                echo -e ""
                echo -e "${cwh}No${cdgy} - Do nothing"
                echo -e ""
            ;;
        esac
    done
}


task_generate_age_secrets() {
    mkdir -p "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/
    chmod 700 "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/
    ssh-to-age -private-key -i "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key > "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    sudo chown root:root "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    sudo chmod 400 "${_dir_remote_rootfs}"/"${feature_impermanence}"/root/.config/sops/age/keys.txt
    export _age_key_pub=$(cat "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age )
    if [ "${1}" = "new" ]; then task_generate_age_secrets_new=true; fi
}

task_generate_encryption_password() {
    if var_true "${disk_encryption}"; then
        # Encryption
        password_encryption_1=$RANDOM
        password_encryption_2=$RANDOM
        counter=1

        while [ "$password_encryption_1" != "$password_encryption_2" ]; do
            if [ $counter -gt 1 ] ; then print_error "Passwords don't match, please reenter" ; fi ;
            read -s -e -p "$(echo -e ${cdgy}${cwh}** ${cdgy} Enter Disk Encryption Password: \ ${coff})" password_encryption_1
            echo ""
            read -s -e -p "$(echo -e ${cdgy}${cwh}** ${cdgy} Confirm Disk Encryption Password: \ ${coff})" password_encryption_2
            echo ""
            (( counter+=1 ))
        done
        PASSWORD_ENCRYPTION=${password_encryption_2}
    fi
}

task_generate_host_secrets() {
    printf "\033c"
    echo -e "${clm}"
    cat << EOF
--------------------------
| Host Secrets Additions |
--------------------------

    HOST SECRETS

    Before you can do anything you'll need to crete an example secret.
    Create an example secret. Delete everything in the file and replace it with the following line:

${deploy_host}: Example secret for ${deploy_host}
EOF

    wait_for_keypress
    mkdir -p "${_dir_flake}"/hosts/"${deploy_host}"/secrets
    sops "${_dir_flake}"/hosts/"${deploy_host}"/secrets/secrets.yaml
    git add "${_dir_flake}"/hosts/"${deploy_host}"/secrets/secrets.yaml

    if [ "${1}" = "new" ]; then task_generate_host_secrets_new=true; fi
}

task_generate_sops_configuration() {
    touch "${_dir_flake}"/.sops.yaml
    yq -i eval ".keys += [ \"&host_${deploy_host} ${_age_key_pub}\" ]" "${_dir_flake}"/.sops.yaml
    print_debug "Add the hosts AGE Key at the top"

    yq -i eval ".creation_rules += [{\"path_regex\": \"hosts/${deploy_host}/secrets/.*\", \"key_groups\": [{\"age\": [\"*host_${deploy_host}\", \"*host_${SECRET_HOST}\", \"*user_${SECRET_USER}\"]}]}]" "${_dir_flake}"/.sops.yaml

    if [ -n "${SECRET_HOST}" ]; then
        secret_hosts=$(echo "${SECRET_HOST}" | tr "," "\n" | uniq)
        for secret_host in $secret_hosts ; do
            yq -i eval ".creation_rules |= map(select(.path_regex == \"hosts/${deploy_host}/secrets/.*\").key_groups[0].age += [\"*host_${secret_host}\"] // .)" "${_dir_flake}"/.sops.yaml
	    done
    fi

    if [ -n "${SECRET_USER}" ]; then
        secret_users=$(echo "${SECRET_USER}" | tr "," "\n" | uniq)
        for secret_user in $secret_users ; do
            yq -i eval ".creation_rules |= map(select(.path_regex == \"hosts/${deploy_host}/secrets/.*\").key_groups[0].age += [\"*user_${secret_user}\"] // .)" "${_dir_flake}"/.sops.yaml
	    done
    fi

    print_debug "Add the new path_regex for the host along with the host and user"

    yq -i eval ".creation_rules |= map(select(.path_regex == \"hosts/common/secrets/.*\").key_groups[0].age += [\"*host_${deploy_host}\"] // .)" "${_dir_flake}"/.sops.yaml
    print_debug "Add the host to hosts/common/secrets"

    yq -i eval ".creation_rules |= map(select(.path_regex == \"users/secrets.yaml\").key_groups[0].age += [\"*host_${deploy_host}\"] // .)" "${_dir_flake}"/.sops.yaml
    print_debug "Add the host to the users_secrets"

    sed -i "s|'||g" "${_dir_flake}"/.sops.yaml

    if [ "${1}" = "new" ]; then task_generate_sops_configuration_new=true; fi
}

task_generate_ssh_key() {
    _dir_remote_rootfs=$(mktemp -d)
    mkdir -p "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/
    chmod 755 "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/
    ssh-keygen -q -N "" -t ed25519 -C "${deploy_host}" -f "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key
    mkdir -p hosts/"${deploy_host}"/secrets
    cp -R "${_dir_remote_rootfs}"/"${feature_impermanence}"/etc/ssh/ssh_host_ed25519_key.pub hosts/"${deploy_host}"/secrets/
    silent git add "${_dir_flake}"/hosts/"${deploy_host}"
    if [ "${1}" = "new" ]; then task_generate_ssh_key_new=true; fi
}

task_hostmanagement_create() {
    local _host_created

    printf "\033c"
    cat << EOF
-----------------
| Host Creation |
-----------------

    A series of questions will be asked in order to create your new host based on templates.

EOF

    echo -e "${clm}"

    counter=1
    deploy_host=" "
    while [[ $deploy_host = *" "* ]];  do
        if [ $counter -gt 1 ] ; then print_error "Hostnames can't have spaces or dots in them, please re-enter." ; fi ;
            read -e -i "${deploy_host}" -p "$(echo -e ${cdgy}${cwh}** ${cdgy}What is the hostname you are looking to create?\: \ ${coff})" deploy_host
            (( counter+=1 ))
    done

    while [[ ${_host_created,,} != "true" ]];  do
        case "${deploy_host}" in
            quit )
                break
            ;;
            * )
                if [ ! -f "${_dir_flake}"/hosts/"${deploy_host}"/default.nix ] ; then
                    task_hostmanagement_q_role
                    mkdir -p "${_dir_flake}"/hosts/"${deploy_host}"
                    cp -R "${_dir_flake}"/templates/host/${template_role}.nix "${_dir_flake}"/hosts/"${deploy_host}"/default.nix
                    silent git add "${_dir_flake}"/hosts/"${deploy_host}"
                    sed -i \
                            -e "s|hostname = \".*\";|hostname = \"${deploy_host}\";|g" \
                            -e "s|encryption.enable = .*;|encryption.enable = ${_template_encryption};|g" \
                            -e "s|impermanence.enable = .*;|impermanence.enable = ${_template_impermanence};|g" \
                            -e "s|raid.enable = .*;|raid.enable = ${_template_raid};|g" \
                        "${_dir_flake}"/hosts/"${deploy_host}"/default.nix
                    if var_true "${_template_ip_wired}" ; then
                        case "${_template_ip_type}" in
                            dynamic )
                                sed -i "/hostname = \".*\";/a\      wired = {\n       enable = true;\n       type = \"dynamic\";\n       mac = \"${_template_network_mac}\";\n      };\n" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix
                                sed -i "/wired..* = .*;/d" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix
                            ;;
                            static )
                                sed "/hostname = \".*\";/a\      wired = {\n       enable = true;\n       type = \"static\";\n       ip = \"${_template_network_ip}/${_template_network_subnet}\";\n       gateway = \"${_template_network_gateway}\";\n       mac = \"${_template_network_mac}\";\n      };\n" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix
                                sed -i "/wired..* = .*;/d" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix
                            ;;
                        esac
                    fi

                    ## Don't change the indenting on any of this!
                    sed -i "/nixosConfigurations = {/a\\
        ${deploy_host} = lib.nixosSystem { # ${template_role^} Added $(date +"%Y-%m-%d") \n\
          modules = [ .\/hosts\/${deploy_host} ];\n\
          specialArgs = { inherit inputs outputs; };\n\
        };\n" \
                    "${_dir_flake}"/flake.nix
                    silent git add "${_dir_flake}"/flake.nix
                    _host_created=true
                else
                    print_error "Host Configuration already exists! Please choose a new name.."
                    sleep 5
                fi
            ;;
        esac

    done
    unset _host_created
}

task_hostmanagement_delete() {
    COLUMNS=12
    prompt="Which host do you want to delete?"
    options=( $(find ${_dir_flake}/hosts/* -maxdepth 0 -type d | rev | cut -d / -f 1 | rev | sed "/common/d" | xargs -0) )
    PS3="$prompt "
    select opt in "${options[@]}" "Back" ; do
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

    rm -rf -i "${_dir_flake}"/hosts/"${opt}"
    git add .

    sed -i -e "/${opt} = lib.nixosSystem/,/\ \ };/d" "${_dir_flake}"/flake.nix
    silent git add "${_dir_flake}"/flake.nix
}

task_install_host() {
    echo ""
    print_info "Commencing install to Host: ${deploy_host} (${REMOTE_IP})"

    if var_false "${INSTALL_BUILD_LOCAL}" ; then
        feature_build_remote="--build-on-remote"
    fi

    if var_false "${INSTALL_REBOOT}" ; then
        feature_reboot="--no-reboot"
    fi

    if var_true "${INSTALL_DEBUG}" ; then
        feature_debug="--debug"
    fi

    if [ -n "${PASSWORD_ENCRYPTION}" ]; then
        luks_key=$(mktemp)
        echo -n "${PASSWORD_ENCRYPTION}" > "${luks_key}"
        feature_luks="--disk-encryption-keys /tmp/secret.key ${luks_key}"
    fi

    if [ -n "${SSH_PRIVATE_KEY}" ] ; then
        feature_ssh_key="-i ${SSH_PRIVATE_KEY}"
    fi

    ## TODO
    ## We use sudo here as we're generating secrets and setting them as root and when nixosanywhere rsyncs them over it can't read them..
    ## Potential PR to the nixos project to execute a "pre-hook" bash script before the installation process actually occurs.
    if var_true "${INSTALL_DEBUG}" ; then set -x ; fi
    sudo nix run github:numtide/nixos-anywhere -- \
                                                --ssh-port ${SSH_PORT} ${feature_build_remote} ${feature_debug} ${feature_reboot} ${feature_ssh_key} \
                                                ${feature_luks} --extra-files "${_dir_remote_rootfs}" \
                                                --flake "${_dir_flake}"/#${deploy_host} \
                                                ${REMOTE_USER}@${REMOTE_IP}

    if [ -n "${PASSWORD_ENCRYPTION}" ]; then
        rm -rf "${luks_key}"
    fi
    if var_true "${INSTALL_DEBUG}" ; then set +x ; fi
    wait_for_keypress
}

task_parse_disk_config() {
    system_role=$(grep "role = .*;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix | cut -d '"' -f2)

    if grep -qF "btrfs.enable = mkDefault true;" "${_dir_flake}"/modules/roles/"${system_role}"/default.nix; then
        disk_btrfs=true
    fi
    if grep -qF "encryption.enable = mkDefault true;" "${_dir_flake}"/modules/roles/"${system_role}"/default.nix; then
        disk_encryption=true
    fi
    if grep -qF "impermanence.enable = mkDefault true;" "${_dir_flake}"/modules/roles/"${system_role}"/default.nix || grep -qPzo -m 1 "(?s)impermanence = {\n.*enable = mkDefault true;"  "${_dir_flake}"/modules/roles/"${system_role}"/default.nix; then
        disk_impermanence=true
        feature_impermanence="persist"
    fi
    if grep -qF "raid.enable = mkDefault true;" "${_dir_flake}"/modules/roles/"${system_role}"/default.nix; then
        disk_raid=true
    fi
    if grep -qF "swap_file.enable = mkDefault true;" "${_dir_flake}"/modules/roles/"${system_role}"/default.nix; then
        disk_swapfile=true
    fi

    if grep -qF "btrfs.enable = true;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix; then
        disk_btrfs=true
    elif grep -qF "btrfs.enable = false;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix; then
        disk_btrfs=false
    fi
    if grep -qF "encryption.enable = true;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix; then
        disk_encryption=true
    elif grep -qF "encryption.enable = false;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix; then
        disk_encryption=false
    fi
    if grep -qF "impermanence.enable = true;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix || grep -qPzo -m 1 "(?s)impermanence = {\n.*enable = true;" "${_dir_flake}"/modules/roles/"${system_role}"/default.nix ; then
        disk_impermanence=true
        feature_impermanence="persist"
    elif grep -qF "impermanence.enable = false;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix || grep -qPzo -m 1 "(?s)impermanence = {\n.*enable = false;" "${_dir_flake}"/modules/roles/"${system_role}"/default.nix ; then
        disk_impermanence=false
        unset feature_impermanence
    fi
    if grep -qF "raid.enable = true;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix; then
        disk_raid=true
    elif grep -qF "raid.enable = false;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix; then
        disk_raid=false
    fi
    if grep -qF "swap_file.enable = true;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix; then
        disk_swapfile=true
    elif grep -qF "swap_file.enable = false;" "${_dir_flake}"/hosts/"${deploy_host}"/default.nix; then
        disk_swapfile=false
    fi

    _template_chooser=$(mktemp)

    find "${_dir_flake}"/templates/disko/*.nix -maxdepth 0 -type f | rev | cut -d / -f 1 | rev > "${_template_chooser}"

    if var_false "${disk_btrfs}" ; then
        sed -i "/btrfs/d" "${_template_chooser}"
    else
        sed -i -n "/btrfs/p" "${_template_chooser}"
    fi

    if var_false "${disk_encryption}" ; then
        sed -i "/luks/d" "${_template_chooser}"
    else
        sed -i -n "/luks/p" "${_template_chooser}"
    fi

    if var_false "${disk_impermanence}" ; then
        sed -i "/impermanence/d" "${_template_chooser}"
    else
        sed -i -n "/impermanence/p" "${_template_chooser}"
    fi

    if var_false "${disk_raid}" ; then
        sed -i "/raid/d" "${_template_chooser}"
    else
        sed -i -n "/raid/p" "${_template_chooser}"
    fi

    if var_false "${disk_swapfile}" ; then
        sed -i "/swapfile/d" "${_template_chooser}"
    fi

    if [[ "$(wc -l "${_template_chooser}" | awk '{print $1}')" -lt 1 ]]; then
        print_warn "No Disk Template found with the settings in the hosts configuration file"
        print_warn "Please choose a template manually.."
        wait_for_keypress
        task_q_select_disktemplate
    fi

    if [[ "$(wc -l "${_template_chooser}" | awk '{print $1}')" -gt 1 ]]; then
        print_warn "More than two disk templates found based on the settings in the hosts configuration file"
        print_warn "Please choose a template manually.."
        wait_for_keypress
        task_q_select_disktemplate
    fi

    if [ -z "${deploy_disk_template}" ] ; then
        deploy_disk_template="$(cat "${_template_chooser}")"
        cp -i "${_dir_flake}"/templates/disko/${deploy_disk_template} "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix
        task_update_disk_prefix
    fi

    rm -rf "${_template_chooser}"
}

task_q_select_disktemplate() {
    COLUMNS=12
    prompt="Which Disk template do you want to deploy?"
    options=( $(find ${_dir_flake}/templates/disko/* -maxdepth 0 -type f | rev | cut -d / -f 1 | rev | sed "s|.nix||g" | xargs -0) )
    PS3="$prompt "
    select opt in "${options[@]}" "Back" ; do
        if (( REPLY == 1 + ${#options[@]} )) ; then
            break
        elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
            break
        else
            echo "Invalid option. Try another one."
        fi
    done
    COLUMNS=$oldcolumns
    export deploy_disk_template=${opt}
    cp -i "${_dir_flake}"/templates/disko/${deploy_disk_template} "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix
    silent git add "${_dir_flake}"/hosts/"${deploy_host}"
    task_update_disk_prefix
}

task_secret_rekey() {
    rekey() {
        for secret_path in $(find $1 -type d); do
            for secret in ${secret_path}/*; do
                if ! [[ $(basename "${secret}") =~ ssh_host.*\.pub|ssh.pub|.*\.nix ]] ; then
                    print_debug "[secret_rekey] Rekeying ${secret}"
                    if var_true "${secret_rekey_silent}"; then
                        yes | silent sops updatekeys "${secret}"
                    else
                        sops updatekeys "${secret}"
                    fi
                fi
            done
        done
    }

    if var_true "${secret_rekey_silent}"; then
        :
    else
        echo ""
        print_info "Rekeying Secrets. Please select y or n when prompted"
    fi

    case "${1}" in
        all )
            print_debug "[secret_rekey] Rekeying ALL"
            rekey "${_dir_flake}"/hosts/*/secrets/
            rekey "${_dir_flake}"/users/
        ;;
        common )
            print_debug "[secret_rekey] Rekeying Common"
            rekey "${_dir_flake}"/hosts/common/secrets/
        ;;
        users )
            print_debug "[secret_rekey] Rekeying Users - users/secrets.yaml"
            rekey "${_dir_flake}"/users/
        ;;
        * )
            print_debug "[secret_rekey] Rekeying Wildcard ${1}"
            rekey "${_dir_flake}"/hosts/${1}/secrets/
        ;;
    esac
    if var_nottrue "${secret_rekey_silent}"; then wait_for_keypress; fi
}

task_set_ip_address() {
    counter=1
    local _remote_ip_tmp
    _remote_ip_tmp=256.256.256.256
    until ( valid_ip $_remote_ip_tmp ) ; do
        if [ $counter -gt 1 ] ; then print_error "IP or Hostname is bad, please reenter" ; fi ;
            read -e -p "$(echo -e ${clg}** ${cdgy}Remote Host IP Address: \ ${coff})" _remote_ip_tmp
        (( counter+=1 ))
    done
    export REMOTE_IP=$_remote_ip_tmp
}

task_ssh_to_host() {
    if [ -n "${SSH_PRIVATE_KEY}" ]; then
        task_ssh_to_host_private_key="-i ${SSH_PRIVATE_KEY}"
    fi

    ssh -p ${SSH_PORT}
    ssh -p ${SSH_PORT} ${task_ssh_to_host_private_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_IP}
}

task_update_disk_prefix() {
    if [ -f "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix ] ; then
        read -e -i "$_rawdisk1" -p "$(echo -e ${cdgy}${cwh}** ${cdgy}Enter Disk Device 1 \(eg /dev/nvme0n1\: \)${coff}) " _rawdisk1
        sed -i "s|rawdisk1 = .*|rawdisk1 = \"${_rawdisk1}\";|g" "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix
        if var_true "${disk_raid}" ; then
            read -e -i "$_rawdisk2" -p "$(echo -e ${cdgy}${cwh}** ${cdgy}Enter Disk Device 2 \(eg /dev/vda2\: \)${coff}) " _rawdisk2
            sed -i "s|rawdisk2 = .*|rawdisk2 = \"${_rawdisk2}\";|g" "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix
        fi
        ## TODO Connect remotely and grab details to perform autodetection
        #num_disks=$(lsblk -np --output TYPE |  grep -c -e ^NAME -e "disk")
        #
        #if [ "$num_disks" -ge 2 ] ; then
        #    echo "[update_disk_prefix] Multiple hard disks detrected"
        #fi
        #
        #case ${num_disks} in
        #    "0" )
        #        print_error "No hard disks found"
        #        read -n 1 -s -r -p "** Press any key to continue **"
        #        return
        #        ;;
        #    "1" )
        #        _rawdisk1=$(lsblk -np --output KNAME,SIZE,TYPE |  grep -e ^NAME -e "disk" | awk '{print $1}')
        #        print_debug "[update_disk_prefix] Selecting ${_rawdisk1} for first disk"
        #        ;;
        #    * )
		#        COLUMNS=12
        #        prompt="Which disk do you want to use?"
        #        PS3="$prompt "
        #		select rawdisk in $(lsblk -np --output KNAME,SIZE,TYPE | grep -e ^NAME -e "disk" | awk '{print $1}' | tr "\n" " "); do
        #            _rawdisk1=${rawdisk}
        #            COLUMNS=$oldcolumns
        #            return
        #        done
        #        ;;
        #esac
        #
		#sed -i "s|rawdisk1 = .*|rawdisk1 = \"${_rawdisk1}\";|g" "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix
        #if var_true "${disk_raid}" ; then
        #    case ${num_disks} in
        #        1 )
        #            print_error "You selected raid however there is only one hard disk"
        #            read -n 1 -s -r -p "** Press any key to continue **"
        #            return
        #            ;;
        #        2 )
        #            _rawdisk2=$(lsblk -np --output KNAME,SIZE,TYPE |  grep -e ^NAME -e "disk" | awk '{print $1}' | grep -Pv "${_rawdisk1}")
        #            print_debug "[update_disk_prefix] Selecting ${_rawdisk1} for first disk"
        #            ;;
        #        * )
        #            COLUMNS=12
        #            prompt="Which disk do you want to use for your 2nd RAID disk. (Primary is: ${_rawdisk1}) ?"
        #            PS3="$prompt "
        #            select rawdisk in $(lsblk -np --output KNAME,SIZE,TYPE | grep -e ^NAME -e "disk" | awk '{print $1}' | grep -Pv "${_rawdisk1}" | tr "\n" " "); do
        #                _rawdisk2=${rawdisk}
        #                COLUMNS=$oldcolumns
        #                return
        #            done
        #            ;;
        #    esac
        #    sed -i "s|rawdisk2 = .*|rawdisk2 = \"${_rawdisk2}\";|g" "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix
        #fi
    fi
}

task_update_host() {
    print_info "Commencing update to remote host"
    if [ -n "${SSH_PRIVATE_KEY}" ]; then
        task_update_host_ssh_private_key="-i ${SSH_PRIVATE_KEY}"
    fi
    NIX_SSHOPTS="-t -p ${SSH_PORT} ${task_update_host_ssh_private_key} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" nixos-rebuild switch --flake "${_dir_flake}"/#${deploy_host} --use-remote-sudo --target-host ${REMOTE_USER}@${REMOTE_IP} --use-remote-sudo
    wait_for_keypress
}

task_update_swap_size() {
    if [ -f "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix ] ; then
        read -e -i "$DISK_SWAP_SIZE_GB" -p "$(echo -e ${cdgy}${cwh}** ${cdgy}Disk Swap Size in GB\: \ ${coff}) " DISK_SWAP_SIZE_GB
        sed -i "s|size = ".*"; # SWAP - Do not Delete this comment|size = \"${DISK_SWAP_SIZE_GB}G\"; # SWAP - Do not Delete this comment|g" "${_dir_flake}"/hosts/"${deploy_host}"/disks.nix
    fi
}

################ FUNCTIONS END

trap ctrl_c INT

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
        task_set_ip_address
        menu_host
    ;;
    flake )
        check_dependencies git
        check_dependencies nix
        if [ -n "${2}" ] ; then
            case "${2}" in
                update )
                    flake_tools update
                    wait_for_keypress
                    exit
                ;;
                upgrade )
                    flake_tools upgrade
                    wait_for_keypress
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

