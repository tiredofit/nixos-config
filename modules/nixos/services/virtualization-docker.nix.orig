{ config, pkgs, ... }:
{
  environment = {
    etc = {
      "docker/daemon.json" = {
        text = ''
{
  "experimental": true,
  "live-restore": true,
  "shutdown-timeout": 120
}
        '';
        mode = "0600";
      };
    };
    persistence."/persist" = {
      hideMounts = true ;
      directories = [
        "/var/lib/docker"                  # Docker
      ];
    };

    systemPackages = with pkgs; [
      docker-compose
    ];
  };

  programs = {
    bash = {
      shellInit = ''
### Docker

export DOCKER_TIMEOUT=$DOCKER_TIMEOUT:-"120"

# Figure out if we need to use sudo for docker commands
if id -nG "$USER" | grep -qw "docker" || [ $(id -u) = "0" ]; then
    dsudo=""
else
    dsudo='sudo'
fi

alias dpsa="$dsudo docker_ps -a"                                               # Get process included stop container
alias di="$dsudo docker images"                                                # Get images
alias dki="$dsudo docker run -it -P"                                           # Run interactive container, e.g., $dki base /bin/bash
alias dex="$dsudo docker exec -it"                                             # Execute interactive container, e.g., $dex base /bin/bash
dstop() { $dsudo docker stop $($dsudo docker ps -a -q) -t $DOCKER_TIMEOUT; }   # Stop all containers
#drm() { $dsudo docker rm $($dsudo docker ps -a -q); }                                                                                    # Remove all containers
#dri() { $dsudo docker rmi -f $($dsudo docker images -q); }                                                                               # Forcefully Remove all images
#drmf() { $dsudo docker stop $($dsudo docker ps -a -q) -timeout $DOCKER_COMPOSE_TIMEOUT && $dsudo docker rm $($dsudo docker ps -a -q) ; } # Stop and remove all containers
db() { $dsudo docker build -t="$1" .; } # Build Docker Image from Current Directory

# Get RAM Usage of a Container
docker_mem() {
    if [ -f /sys/fs/cgroup/memory/docker/"$1"/memory.usage_in_bytes ]; then
        echo $(($(cat /sys/fs/cgroup/memory/docker/"$1"/memory.usage_in_bytes) / 1024 / 1024)) 'MB'
    else
        echo 'n/a'
    fi
}
alias dmem='docker_mem'

# Get IP Address of a Container
docker_ip() {
    ip=$($dsudo docker inspect --format="{{.NetworkSettings.IPAddress}}" "$1" 2>/dev/null)
    if (($? >= 1)); then
        # Container doesn't exist
        ip='n/a'
    fi
    echo $ip
}
alias dip='docker_ip'

# Enhanced version of 'docker ps' which outputs two extra columns IP and RAM
docker_ps() {
    tmp=$($dsudo docker ps "$@")
    headings=$(echo "$tmp" | head --lines=1)
    max_len=$(echo "$tmp" | wc --max-line-length)
    dps=$(echo "$tmp" | tail --lines=+2)
    printf "%-''${max_len}s %-15s %10s\n" "$headings" IP RAM

    if [[ -n "$dps" ]]; then
        while read -r line; do
            container_short_hash=$(echo "$line" | cut -d' ' -f1)
            container_long_hash=$($dsudo docker inspect --format="{{.Id}}" "$container_short_hash")
            container_name=$(echo "$line" | rev | cut -d' ' -f1 | rev)
            if [ -n "$container_long_hash" ]; then
                ram=$(docker_mem "$container_long_hash")
                ip=$(docker_ip "$container_name")
                printf "%-''${max_len}s %-15s %10s\n" "$line" "$ip" "$ram"
            fi
        done <<<"$dps"
    fi

}
alias dps='docker_ps'

#  List the volumes for a given container
docker_vol() {
    vols=$($dsudo docker inspect --format="{{.HostConfig.Binds}}" "$1")
    vols=''${vols:1:-1}
    for vol in $vols; do
        echo "$vol"
    done
}

alias dvol='docker_vol'

if command -v "fzf" &>/dev/null; then
    # bash into running container
    alias dbash='c_name=$($dsudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{ .ID}}\t{{.RunningFor}}" | sed "/NAMES/d" | sort | fzf --tac | awk '"'"'{print $1;}'"'"') ; echo -e "\e[41m**\e[0m Entering $c_name from $(cat /etc/hostname)" ; $dsudo docker exec -e COLUMNS=$( tput cols ) -e LINES=$( tput lines ) -it $c_name bash'

    # sh into running container
    alias dsh='c_name=$($dsudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{ .ID}}\t{{.RunningFor}}" | sed "/NAMES/d" | sort | fzf --tac | awk '"'"'{print $1;}'"'"') ; echo -e "\e[41m**\e[0m Entering $c_name from $(cat /etc/hostname)" ; $dsudo docker exec -e COLUMNS=$( tput cols ) -e LINES=$( tput lines ) -it $c_name sh'

    # Remove running container
    alias drm='$dsudo docker rm $( $dsudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{ .ID}}\t{{.RunningFor}}" | sed "/NAMES/d" | sort | fzf --tac | awk '"'"'{print $1;}'"'"' )'
fi

### Docker Compose
export DOCKER_COMPOSE_TIMEOUT=''${DOCKER_COMPOSE_TIMEOUT:-"120"}
docker_compose_location=$(which docker-compose)

container_tool() {
    DOCKER_COMPOSE_STACK_DATA_PATH=''${DOCKER_COMPOSE_STACK_DATA_PATH:-"/var/local/data/"}
    DOCKER_COMPOSE_STACK_SYSTEM_DATA_PATH=''${DOCKER_COMPOSE_STACK_SYSTEM_DATA_PATH:-"/var/local/data/_system/"}
    DOCKER_COMPOSE_STACK_APP_RESTART_FIRST=''${DOCKER_COMPOSE_STACK_APP_RESTART_FIRST:-"auth.example.com"}
    DOCKER_COMPOSE_STACK_SYSTEM_APP_RESTART_ORDER=''${DOCKER_COMPOSE_STACK_SYSTEM_APP_RESTART_ORDER:-"socket-proxy tinc error-pages traefik unbound openldap postfix-relay llng-handler restic clamav zabbix"}

    ###
    #  system directory: $DOCKER_COMPOSE_STACK_SYSTEM_DATA_PATH
    #  application directory: $DOCKER_COMPOSE_STACK_DATA_PATH
    #  order to start containers:
    #  1. if $DOCKER_COMPOSE_STACK_APP_RESTART_FIRST (under $DOCKER_COMPOSE_STACK_DATA_PATH), restart first
    #  2. restart containers under system directory in the order of:
    #     \DOCKER_COMPOSE_STACK_SYSTEM_APP_RESTART_ORDER
    #  3. restart containers under application directory (no particular order)
    #
    #  Usage:
    #  container-tool core
    #  container-tool applications
    #  container-tool (default - all)
    #  container-tool stop
    ###

    ct_pull_images () {
        for stack_dir in "$@" ; do
            if [ ! -f "$stack_dir"/.norestart ]; then
                echo "**** [container-tool] [pull] Pulling Images - $stack_dir"
                $docker_compose_location -f "$stack_dir"/*compose.yml pull
            else
                echo "**** [container-tool] [pull] Skipping - $stack_dir"
            fi
        done
    }

    ct_pull_restart () {
        for stack_dir in "$@" ; do
            if [ ! -f "$stack_dir"/.norestart ]; then
                echo "**** [container-tool] [pull_restart] Pulling Images - $stack_dir"
                $docker_compose_location -f "$stack_dir"/*compose.yml pull
                echo "**** [container-tool] [pull_restart] Bringing up stack - $stack_dir"
                $docker_compose_location -f "$stack_dir"/*compose.yml up -d
            else
                echo "**** [container-tool] [pull_restart] Skipping - $stack_dir"
            fi
        done
    }

    ct_restart () {
        for stack_dir in "$@" ; do
            if [ ! -f "$stack_dir"/.norestart ]; then
                echo "**** [container-tool] [restart] Bringing down stack - $stack_dir"
                $docker_compose_location -f "$stack_dir"/*compose.yml down --timeout $DOCKER_COMPOSE_TIMEOUT
                echo "**** [container-tool] [restart] Bringing up stack - $stack_dir"
                $docker_compose_location -f "$stack_dir"/*compose.yml up -d
            else
                echo "**** [container-tool] [restart] Skipping - $stack_dir"
            fi
        done
    }

    ct_stop () {
        for stack_dir in "$@" ; do
                echo "**** [container-tool] [restart] Stopping stack - $stack_dir"
                $docker_compose_location -f "$stack_dir"/*compose.yml down --timeout $DOCKER_COMPOSE_TIMEOUT
        done
    }

    ct_sort_order () {
        local -n tmparr=$1
        index=0

        for i in ''${!predef_order[*]} ; do
            for j in ''${!tmparr[*]} ; do
                tmpitem="''${tmparr[$j]}"
                if [ ''${predef_order[$i]} == $(basename "''${tmpitem::-1}") ]; then
                tmpitem=''${tmparr[$index]}
                tmparr[$index]="''${tmparr[$j]}"
                tmparr[$j]=$tmpitem
                let "index++"
                break
                fi
            done
        done
    }

    ct_restart_sys_containers () {
        # the order to restart system containers:
        predef_order=($(echo "$DOCKER_COMPOSE_STACK_SYSTEM_APP_RESTART_ORDER"))

        curr_order=()

        for stack_dir in "$DOCKER_COMPOSE_STACK_SYSTEM_DATA_PATH"/*/ ; do
            if [ -s "$stack_dir"/*compose.yml ]; then
                curr_order=("''${curr_order[@]}" "$stack_dir")
            fi
        done

        # pass the array by reference
        ct_sort_order curr_order
        ct_restart "''${curr_order[@]}"
    }

    ct_stop_stack () {
        stacks=$($docker_compose_location ls | tail -n +2 | awk '{print $1}')
        for stack in $stacks; do
            stack_image=$($docker_compose_location -p $stack images | tail -n +2 | awk '{print $1,$2}' | grep "db-backup")
                if [ "$1" != "nobackup" ] ; then
                    if [[ $stack_image =~ .*"db-backup".* ]] ; then
                        stack_container_name=$(echo "$stack_image" | awk '{print $1}')
                        echo "** Backing up database for '$stack_container_name' before stopping"
                        docker exec $stack_container_name /usr/local/bin/backup-now
                    fi
                fi
            echo "** Gracefully stopping compose stack: $stack"
            $docker_compose_location -p $stack down --timeout $DOCKER_COMPOSE_TIMEOUT
        done
    }

    ct_stop_sys_containers () {
        # the order to restart system containers:
        #predef_order=(tinc openldap unbound traefik error-pages postfix-relay llng-handler clamav zabbix fluent-bit)
        predef_order=($(echo "$DOCKER_COMPOSE_STACK_SYSTEM_APP_RESTART_ORDER"))

        curr_order=()

        for stack_dir in "$DOCKER_COMPOSE_STACK_SYSTEM_DATA_PATH"/*/ ; do
            if [ -s "$stack_dir"/*compose.yml ]; then
                curr_order=("''${curr_order[@]}" "$stack_dir")
            fi
        done

        # pass the array by reference
        ct_sort_order curr_order
        ct_stop "''${curr_order[@]}"
    }

    ct_pull_restart_containers () {
        # the order to restart system containers:
        predef_order=($(echo "$DOCKER_COMPOSE_STACK_SYSTEM_APP_RESTART_ORDER"))

        curr_order=()

        for stack_dir in "$DOCKER_COMPOSE_STACK_SYSTEM_DATA_PATH"/*/ ; do
            if [ -s "$stack_dir"/*compose.yml ]; then
                curr_order=("''${curr_order[@]}" "$stack_dir")
            fi
        done

        # pass the array by reference
        ct_sort_order curr_order

        #echo "''${curr_order[@]}"
        if [ "$1" = restart ] ; then
            ct_pull_restart "''${curr_order[@]}"
        else
            ct_pull_images "''${curr_order[@]}"
        fi

        # there is no particular order to retart application containers
        # except the DOCKER_COMPOSE_STACK_APP_RESTART_FIRST, which should be restarted as the
        # first container, even before system containers
        curr_order=()

        for stack_dir in "$DOCKER_COMPOSE_STACK_DATA_PATH"/*/ ; do
            if [ "$DOCKER_COMPOSE_STACK_DATA_PATH""$DOCKER_COMPOSE_STACK_APP_RESTART_FIRST" != "$stack_dir" ] && [ -s "$stack_dir"/*compose.yml ]; then
                curr_order=("''${curr_order[@]}" "$stack_dir")
            fi
        done

        # no need to sort order
        if [ "$1" = restart ] ; then
            ct_pull_restart "''${curr_order[@]}"
        else
            ct_pull_images "''${curr_order[@]}"
        fi
    }

    ct_restart_app_containers () {
        # there is no particular order to retart application containers
        # except the DOCKER_COMPOSE_STACK_APP_RESTART_FIRST, which should be restarted as the
        # first container, even before system containers
        curr_order=()

        for stack_dir in "$DOCKER_COMPOSE_STACK_DATA_PATH"/*/ ; do
            if [ "$DOCKER_COMPOSE_STACK_DATA_PATH""$DOCKER_COMPOSE_STACK_APP_RESTART_FIRST" != "$stack_dir" ] && [ -s "$stack_dir"/*compose.yml ]; then
                curr_order=("''${curr_order[@]}" "$stack_dir")
            fi
        done

        # no need to sort order
        ct_restart "''${curr_order[@]}"
    }

    ct_stop_app_containers () {
        # there is no particular order to retart application containers
        # except the DOCKER_COMPOSE_STACK_APP_RESTART_FIRST, which should be restarted as the
        # first container, even before system containers
        curr_order=()

        for stack_dir in "$DOCKER_COMPOSE_STACK_DATA_PATH"/*/ ; do
            if [ "$DOCKER_COMPOSE_STACK_DATA_PATH""$DOCKER_COMPOSE_STACK_APP_RESTART_FIRST" != "$stack_dir" ] && [ -s "$stack_dir"/*compose.yml ]; then
                curr_order=("''${curr_order[@]}" "$stack_dir")
            fi
        done

        # no need to sort order
        ct_stop "''${curr_order[@]}"
    }

    ct_restart_first () {
        if [ -s "$DOCKER_COMPOSE_STACK_DATA_PATH""$DOCKER_COMPOSE_STACK_APP_RESTART_FIRST"/*compose.yml ]; then
                echo "**** [container-tool] [restart_first] Bringing down stack - $DOCKER_COMPOSE_STACK_DATA_PATH$DOCKER_COMPOSE_STACK_APP_RESTART_FIRST"
                $docker_compose_location -f "$DOCKER_COMPOSE_STACK_DATA_PATH"/"$DOCKER_COMPOSE_STACK_APP_RESTART_FIRST"/*compose.yml down --timeout $DOCKER_COMPOSE_TIMEOUT
                echo "**** [container-tool] [restart_first] Bringing up stack - $DOCKER_COMPOSE_STACK_DATA_PATH$DOCKER_COMPOSE_STACK_APP_RESTART_FIRST"
                $docker_compose_location -f "$DOCKER_COMPOSE_STACK_DATA_PATH"/"$DOCKER_COMPOSE_STACK_APP_RESTART_FIRST"/*compose.yml up -d
        fi
    }

    if [ "$#" -gt 2 ] || { [ "$#" -eq 2 ] && [ "$2" != "--debug" ]; } then
        echo $"Usage:"
        echo "  $0 {core|applications|apps|pull|--all}"
        echo "  $0 -h|--help"
        exit 1
    fi

    if [ "$2" = "--debug" ]; then
        set -x
    fi

    case "$1" in
        core|system)
            echo "**** [container-tool] Restarting Core Applications"
            ct_restart_first           # Restart $DOCKER_COMPOSE_STACK_APP_RESTART_FIRST
            ct_restart_sys_containers  # Restart $DOCKER_COMPOSE_STACK_SYSTEM_DATA_PATH
            if pgrep -x "sssd" >/dev/null ; then
                echo "**** [container-tool] Restarting SSSD"
                systemctl restart sssd
            fi
        ;;
        applications|apps)
            echo "**** [container-tool] Restarting User Applications"
            ct_restart_app_containers  # Restart $DOCKER_COMPOSE_STACK_DATA_PATH
            if pgrep -x "sssd" >/dev/null ; then
                echo "**** [container-tool] Restarting SSSD"
                systemctl restart sssd
            fi
        ;;
        --all|-a)  # restart all containers
            echo "**** [container-tool] Restarting all Containers"
            ct_restart_first
            ct_restart_sys_containers
            ct_restart_app_containers
            if pgrep -x "sssd" >/dev/null ; then
                echo "**** [container-tool] Restarting SSSD"
                systemctl restart sssd
            fi
        ;;
        pull) # Pull new images
            if [ "$2" = "restart" ] ; then pull_str="and restarting containers" ; fi
            echo "**** [container-tool] Pulling all images $pull_str for compose.yml files (!= .norestart)"
            ct_pull_restart_containers $2
        ;;
        shutdown) # stop all containers via compose stack
            if [ "$2" = "nobackup" ] ; then shutdown_str="NOT" ; fi
            echo "**** [container-tool] Stopping all compose stacks and $shutdown_str backing up databases if a db-backup container exists"
            ct_stop_stack
        ;;
        stop) # stop all containers
            echo "**** [container-tool] Stopping all containers"
            ct_stop_sys_containers
            ct_stop_app_containers
        ;;
        --help|-h)
            echo $"Usage:"
            echo "  contianer-tool {core|applications|shutdown|pull|apps|--all}"
            echo
            echo "  core|system          restart auth and system containers"
            echo "  applications|apps    restart application containers"
            echo "  pull (restart)       pull images with updates. Add restart as second argument to immediately restart"
            echo "  shutdown (nobackup)  Shutdown all docker-compose stacks regardless of what they are - add nobackup argument to skip backing up DB"
            echo "  stop                 stop all containers"
            echo "  --all|-a             restart all core and application containers"
        ;;
        *)
            echo $"Usage:"
            echo "  container-tool {core|applications|apps|pull|shutdown|stop|--all}"
            echo "  container-tool -h|--help"
        ;;
    esac
}

docker-compose() {
        if [ "$2" != "--help" ] ; then
            case "$1" in
                "down" )
                    arg=$(echo "$@" | sed "s|^$1||g")
                    $dsudo $docker_compose_location down --timeout $DOCKER_COMPOSE_TIMEOUT $arg
                ;;
                "restart" )
                    arg=$(echo "$@" | sed "s|^$1||g")
                    $dsudo $docker_compose_location restart --timeout $DOCKER_COMPOSE_TIMEOUT $arg
                ;;
                "stop" )
                    arg=$(echo "$@" | sed "s|^$1||g")
                    $dsudo $docker_compose_location stop --timeout $DOCKER_COMPOSE_TIMEOUT $arg
                ;;
                "up" )
                    arg=$(echo "$@" | sed "s|^$1||g")
                    $dsudo $docker_compose_location up $arg
                ;;
                * )
                    $dsudo $docker_compose_location ''${@}
                ;;
            esac
        fi
}

alias container-tool=container_tool
alias dpull='$dsudo docker pull'                                                                                                 # Docker Pull
alias dcpull='$dsudo docker-compose pull'                                                                                        # Docker-Compose Pull
alias dcu='$dsudo $docker_compose_location up'                                                                                    # Docker-Compose Up
alias dcud='$dsudo $docker_compose_location up -d'                                                                                # Docker-Compose Daemonize
alias dcd='$dsudo $docker_compose_location down --timeout $DOCKER_COMPOSE_TIMEOUT'                                              # Docker-Compose Down
alias dcl='$dsudo $docker_compose_location logs -f'                                                                               # Docker Compose Logs
alias dcrecycle='$dsudo $docker_compose_location down --timeout $DOCKER_COMPOSE_TIMEOUT ; $dsudo $docker_compose_location up -d' # Docker Compose Restart

if [ -n "$1" ] && [ "$1" = "container_tool" ] ; then
    arg=$(echo "$@" | sed "s|^$1||g")
    container_tool $arg
fi
            '';
    };
  };

  system.activationScripts.create_docker_networks = let
    dockerBin = "${pkgs.docker}/bin/docker";
  in ''
     ${dockerBin} network inspect proxy > /dev/null || ${dockerBin} network create proxy --subnet 172.19.0.0/18
     ${dockerBin} network inspect services >/dev/null || ${dockerBin} network create services --subnet 172.19.128.0/18
     ${dockerBin} network inspect socket-proxy >/dev/null || ${dockerBin} network create socket-proxy --subnet 172.19.192.0/18
   '';

  users.groups = {
    docker = {};
  };

  virtualisation = {
     docker = {
       enable = true;
       enableOnBoot = false ;
       logDriver = "local";
       storageDriver = "btrfs";
     };
 };
}
