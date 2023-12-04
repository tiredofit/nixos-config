{config, lib, pkgs, ...}:

with lib;
let
  cfg = config.host.feature.virtualization.docker;

  docker_storage_driver =
    if config.host.filesystem.btrfs.enable
    then "btrfs"
    else "overlay2";

  containercfg = config.host.feature.virtualization.docker.containers;
  proxy_env = config.networking.proxy.envVars;

  containerOptions =
    { ... }: {

      options = {

        image = mkOption {
          type = with types; str;
          description = "Docker image to run.";
          example = "library/hello-world";
        };

        imageFile = mkOption {
          type = with types; nullOr package;
          default = null;
          description = ''
            Path to an image file to load instead of pulling from a registry.
            If defined, do not pull from registry.

            You still need to set the <literal>image</literal> attribute, as it
            will be used as the image name for docker to start a container.
          '';
          example = literalExample "pkgs.dockerTools.buildDockerImage {...};";
        };

        pullonStart = mkOption {
          default = true;
          type = with types; bool;
          description = "Enable support for pulling version on service start";
        };

        login = {
          username = mkOption {
            type = with types; nullOr str;
            default = null;
            description = lib.mdDoc "Username for login.";
          };

          passwordFile = mkOption {
            type = with types; nullOr str;
            default = null;
            description = lib.mdDoc "Path to file containing password.";
            example = "/etc/nixos/dockerhub-password.txt";
          };

          registry = mkOption {
            type = with types; nullOr str;
            default = null;
            description = lib.mdDoc "Registry where to login to.";
            example = "https://docker.pkg.github.com";
          };
        };

        cmd = mkOption {
          type = with types; listOf str;
          default = [];
          description = "Commandline arguments to pass to the image's entrypoint.";
          example = literalExample ''
            ["--port=9000"]
          '';
        };

        entrypoint = mkOption {
          type = with types; nullOr str;
          description = "Overwrite the default entrypoint of the image.";
          default = null;
          example = "/bin/my-app";
        };

        environment = mkOption {
          type = with types; attrsOf str;
          default = {};
          description = "Environment variables to set for this container.";
          example = literalExample ''
            {
              DATABASE_HOST = "db.example.com";
              DATABASE_PORT = "3306";
            }
          '';
        };

        environmentFiles = mkOption {
          type = with types; listOf path;
          default = [];
          description = lib.mdDoc "Environment files for this container.";
          example = literalExpression ''
            [
              /path/to/.env
              /path/to/.env.secret
            ]
        '';
        };

        labels = mkOption {
          type = with types; attrsOf str;
          default = {};
          description = lib.mdDoc "Labels to attach to the container at runtime.";
          example = literalExpression ''
            {
              "traefik.https.routers.example.rule" = "Host(`example.container`)";
            }
          '';
        };

        log-driver = mkOption {
          type = types.str;
          default = "none";
          description = ''
            Logging driver for the container.  The default of
            <literal>"none"</literal> means that the container's logs will be
            handled as part of the systemd unit.  Setting this to
            <literal>"journald"</literal> will result in duplicate logging, but
            the container's logs will be visible to the <command>docker
            logs</command> command.

            For more details and a full list of logging drivers, refer to the
            <link xlink:href="https://docs.docker.com/engine/reference/run/#logging-drivers---log-driver">
            Docker engine documentation</link>
          '';
        };

        networks = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Docker networks to create and connect this container to.

            The first network in this list will be connected with
            <literal>--network=</literal>, others after container
            creation with <command>docker network connect</command>.

            Any networks will be created if they do not exist before
            the container is started.
          '';
        };

        ports = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Network ports to publish from the container to the outer host.

            Valid formats:

            <itemizedlist>
              <listitem>
                <para>
                  <literal>&lt;ip&gt;:&lt;hostPort&gt;:&lt;containerPort&gt;</literal>
                </para>
              </listitem>
              <listitem>
                <para>
                  <literal>&lt;ip&gt;::&lt;containerPort&gt;</literal>
                </para>
              </listitem>
              <listitem>
                <para>
                  <literal>&lt;hostPort&gt;:&lt;containerPort&gt;</literal>
                </para>
              </listitem>
              <listitem>
                <para>
                  <literal>&lt;containerPort&gt;</literal>
                </para>
              </listitem>
            </itemizedlist>

            Both <literal>hostPort</literal> and
            <literal>containerPort</literal> can be specified as a range of
            ports.  When specifying ranges for both, the number of container
            ports in the range must match the number of host ports in the
            range.  Example: <literal>1234-1236:1234-1236/tcp</literal>

            When specifying a range for <literal>hostPort</literal> only, the
            <literal>containerPort</literal> must <emphasis>not</emphasis> be a
            range.  In this case, the container port is published somewhere
            within the specified <literal>hostPort</literal> range.  Example:
            <literal>1234-1236:1234/tcp</literal>

            Refer to the
            <link xlink:href="https://docs.docker.com/engine/reference/run/#expose-incoming-ports">
            Docker engine documentation</link> for full details.
          '';
          example = literalExample ''
            [
              "8080:9000"
            ]
          '';
        };

        user = mkOption {
          type = with types; nullOr str;
          default = null;
          description = ''
            Override the username or UID (and optionally groupname or GID) used
            in the container.
          '';
          example = "nobody:nogroup";
        };

        volumes = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            List of volumes to attach to this container.

            Note that this is a list of <literal>"src:dst"</literal> strings to
            allow for <literal>src</literal> to refer to
            <literal>/nix/store</literal> paths, which would difficult with an
            attribute set.  There are also a variety of mount options available
            as a third field; please refer to the
            <link xlink:href="https://docs.docker.com/engine/reference/run/#volume-shared-filesystems">
            docker engine documentation</link> for details.
          '';
          example = literalExample ''
            [
              "volume_name:/path/inside/container"
              "/path/on/host:/path/inside/container"
            ]
          '';
        };

        workdir = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Override the default working directory for the container.";
          example = "/var/lib/hello_world";
        };

        dependsOn = mkOption {
          type = with types; listOf str;
          default = [];
          description = ''
            Define which other containers this one depends on. They will be added to both After and Requires for the unit.

            Use the same name as the attribute under <literal>services.docker-containers</literal>.
          '';
          example = literalExample ''
            services.docker-containers = {
              node1 = {};
              node2 = {
                dependsOn = [ "node1" ];
              }
                        }
          '';
        };

        extraOptions = mkOption {
          type = with types; listOf str;
          default = [];
          description = "Extra options for <command>docker run</command>.";
          example = literalExample ''
            ["--network=host"]
          '';
        };

        autoStart = mkOption {
          type = types.bool;
          default = true;
          description = lib.mdDoc ''
            When enabled, the container is automatically started on boot.
            If this option is set to false, the container has to be started on-demand via its service.
          '';
        };
      };
    };

  isValidLogin = login: login.username != null && login.passwordFile != null && login.registry != null;

  mkService = name: container: let
    mkAfter = map (x: "docker-${x}.service") container.dependsOn;
  in
    rec {
      wantedBy = [] ++ optional (container.autoStart) "multi-user.target";
      after = [ "docker.service" "docker.socket" ]
        ## TODO Add if we want to optionalize this "docker-networks.service"
        ++ lib.optionals (container.imageFile == null) [ "network-online.target" ]
        ++ mkAfter;
      requires = after;
      environment = proxy_env;

      serviceConfig = {
        ExecStart = [ "${pkgs.docker}/bin/docker start -a ${name}" ];

        ExecStartPre = [
          "-${pkgs.docker}/bin/docker rm -f ${name}"
        ] ++ (
          optional (container.imageFile != null)
            [ "${pkgs.docker}/bin/docker load -i ${container.imageFile}" ]
        ) ++ (

        optional (isValidLogin container.login)
          [ "cat ${container.login.passwordFile} | \
              ${pkgs.docker}/bin/docker login \
                ${container.login.registry} \
                --username ${container.login.username} \
                --password-stdin" ]
        ) ++ (
        optional ((container.imageFile == null) && (container.pullonStart))
          [ "${pkgs.docker}/bin/docker pull ${container.image}" ]
        ) ++ [
          (
            concatStringsSep " \\\n  " (
              [
                "${pkgs.docker}/bin/docker create"
                "--rm"
                "--name=${name}"
                "--log-driver=${container.log-driver}"
              ] ++ optional (container.entrypoint != null)
                "--entrypoint=${escapeShellArg container.entrypoint}"
              ++ (mapAttrsToList (k: v: "-e ${escapeShellArg k}=${escapeShellArg v}") container.environment)
              ++ map (f: "--env-file ${escapeShellArg f}") container.environmentFiles
              ++ map (p: "-p ${escapeShellArg p}") container.ports
              ++ optional (container.user != null) "-u ${escapeShellArg container.user}"
              ++ map (v: "-v ${escapeShellArg v}") container.volumes
              ++ optional (container.workdir != null) "-w ${escapeShellArg container.workdir}"
              ++ optional (container.networks != []) "--network=${escapeShellArg (builtins.head container.networks)}"
              ++ (mapAttrsToList (k: v: "-l ${escapeShellArg k}=${escapeShellArg v}") container.labels)
              ++ map escapeShellArg container.extraOptions
              ++ [ container.image ]
              ++ map escapeShellArg container.cmd
            )
          )
        ] ++ map (n: "${pkgs.docker}/bin/docker network connect ${escapeShellArg n} ${name}") (drop 1 container.networks);

        ExecStop = ''${pkgs.bash}/bin/sh -c "[ $SERVICE_RESULT = success ] || ${pkgs.docker}/bin/docker stop ${name}"'';
        ExecStopPost = "-${pkgs.docker}/bin/docker rm -f ${name}";

        ### There is no generalized way of supporting `reload` for docker
        ### containers. Some containers may respond well to SIGHUP sent to their
        ### init process, but it is not guaranteed; some apps have other reload
        ### mechanisms, some don't have a reload signal at all, and some docker
        ### images just have broken signal handling.  The best compromise in this
        ### case is probably to leave ExecReload undefined, so `systemctl reload`
        ### will at least result in an error instead of potentially undefined
        ### behaviour.
        ###
        ### Advanced users can still override this part of the unit to implement
        ### a custom reload handler, since the result of all this is a normal
        ### systemd service from the perspective of the NixOS module system.
        ###
        # ExecReload = ...;
        ###

        TimeoutStartSec = 0;
        TimeoutStopSec = 120;
        Restart = "always";
      };
    };

in
{
  options = {
    host.feature.virtualization.docker = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables tools and daemon for containerization";
      };
    };
    host.feature.virtualization.docker.containers = mkOption {
      default = {};
      type = types.attrsOf (types.submodule containerOptions);
      description = "Docker containers to run as systemd services.";
    };
  };

  config = mkIf ((cfg.enable) || (containercfg != {})) {
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

      systemPackages = with pkgs; [ docker-compose ];
    };

    host = {
      filesystem = {
        impermanence.directories =
          lib.mkIf config.host.filesystem.impermanence.enable [
            "/var/lib/docker" # Docker
          ];
      };
      service = { docker_container_manager.enable = true; };
    };

    programs = {
      bash = {
        interactiveShellInit = ''
          ### Docker

            if [ -n "$XDG_CONFIG_HOME" ] ; then
                export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
            else
                export DOCKER_CONFIG="$HOME/.config/docker"
            fi

            export DOCKER_TIMEOUT=''${DOCKER_TIMEOUT:-"120"}

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

                # view logs
                alias dlog='c_name=$($dsudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{ .ID}}\t{{.RunningFor}}" | sed "/NAMES/d" | sort | fzf --tac | awk '"'"'{print $1;}'"'"') ; echo -e "\e[41m**\e[0m Viewing $c_name from $(cat /etc/hostname)" ; $dsudo docker logs $c_name $1'

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
              DOCKER_STACK_SYSTEM_DATA_PATH=''${DOCKER_STACK_SYSTEM_DATA_PATH:-"/var/local/data/_system/"}
              DOCKER_COMPOSE_STACK_APP_RESTART_FIRST=''${DOCKER_COMPOSE_STACK_APP_RESTART_FIRST:-"auth.example.com"}
              DOCKER_STACK_SYSTEM_APP_RESTART_ORDER=''${DOCKER_STACK_SYSTEM_APP_RESTART_ORDER:-"socket-proxy tinc error-pages traefik unbound openldap postfix-relay llng-handler restic clamav zabbix"}

              ###
              #  system directory: $DOCKER_STACK_SYSTEM_DATA_PATH
              #  application directory: $DOCKER_COMPOSE_STACK_DATA_PATH
              #  order to start containers:
              #  1. if $DOCKER_COMPOSE_STACK_APP_RESTART_FIRST (under $DOCKER_COMPOSE_STACK_DATA_PATH), restart first
              #  2. restart containers under system directory in the order of:
              #     \DOCKER_STACK_SYSTEM_APP_RESTART_ORDER
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

              ct_restart_service () {
                  for stack_dir in "$@" ; do
                      if [ ! -f "$stack_dir"/.norestart ]; then
                          if systemctl list-unit-files docker-"$stack_dir".service &>/dev/null ; then
                              echo "**** [container-tool] [restart] Bringing down stack - $stack_dir"
                              systemctl stop docker-"$stack_dir".service
                              echo "**** [container-tool] [restart] Bringing up stack - $stack_dir"
                              systemctl start docker-"$stack_dir".service
                          else
                              echo "**** [container-tool] [restart] Skipping - $stack_dir"
                          fi
                      fi
                  done
              }

              ct_stop () {
                  for stack_dir in "$@" ; do
                          echo "**** [container-tool] [stop] Stopping stack - $stack_dir"
                          $docker_compose_location -f "$stack_dir"/*compose.yml down --timeout $DOCKER_COMPOSE_TIMEOUT
                  done
              }

              ct_stop_service() {
                  for stack_dir in "$@" ; do
                      if systemctl list-unit-files docker-"$stack_dir".service &>/dev/null ; then
                          echo "**** [container-tool] [stop_service] Stopping stack - $stack_dir"
                          systemctl stop docker-"$stack_dir".service
                      fi
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
                 set -x
                  # the order to restart system containers:
                  predef_order=($(echo "$DOCKER_STACK_SYSTEM_APP_RESTART_ORDER"))

                  curr_order=()

                  for stack_dir in "$DOCKER_STACK_SYSTEM_DATA_PATH"/* ; do
                      curr_order=("''${curr_order[@]}" "''${stack_dir##*/}")
                  done

                  # pass the array by reference
                  ct_sort_order curr_order
                  ct_restart_service "''${curr_order[@]}"
                set +x
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
                  predef_order=($(echo "$DOCKER_STACK_SYSTEM_APP_RESTART_ORDER"))

                  curr_order=()

                  for stack_dir in "$DOCKER_STACK_SYSTEM_DATA_PATH"/* ; do
                          curr_order=("''${curr_order[@]}" "''${stack_dir##*/}")
                  done

                  # pass the array by reference
                  ct_sort_order curr_order
                  ct_stop_service "''${curr_order[@]}"
              }

              ct_pull_restart_containers () {
                  ## System containers have been moved to systemd
                  # the order to restart system containers:
                  #predef_order=($(echo "$DOCKER_STACK_SYSTEM_APP_RESTART_ORDER"))

                  #curr_order=()

                  #for stack_dir in "$DOCKER_STACK_SYSTEM_DATA_PATH"/*/ ; do
                  #    if [ -s "$stack_dir"/*compose.yml ]; then
                  #        curr_order=("''${curr_order[@]}" "''${stack_dir##*/}")
                  #    fi
                  #done

                  # pass the array by reference
                  #ct_sort_order curr_order

                  #echo "''${curr_order[@]}"
                  #if [ "$1" = restart ] ; then
                  #    ct_pull_restart "''${curr_order[@]}"
                  #else
                  #    ct_pull_images "''${curr_order[@]}"
                  #fi

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
                  set -x
                      echo "**** [container-tool] Restarting Core Applications"
                      ct_restart_first           # Restart $DOCKER_COMPOSE_STACK_APP_RESTART_FIRST
                      ct_restart_sys_containers  # Restart $DOCKER_STACK_SYSTEM_DATA_PATH
                      if pgrep -x "sssd" >/dev/null ; then
                          echo "**** [container-tool] Restarting SSSD"
                          systemctl restart sssd
                      fi
                  set +x
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
          alias dcu='$dsudo $docker_compose_location up'                                                                                   # Docker-Compose Up
          alias dcud='$dsudo $docker_compose_location up -d'                                                                               # Docker-Compose Daemonize
          alias dcd='$dsudo $docker_compose_location down --timeout $DOCKER_COMPOSE_TIMEOUT'                                               # Docker-Compose Down
          alias dcl='$dsudo $docker_compose_location logs -f'                                                                              # Docker Compose Logs
          alias dcrecycle='$dsudo $docker_compose_location down --timeout $DOCKER_COMPOSE_TIMEOUT ; $dsudo $docker_compose_location up -d' # Docker Compose Restart

          if [ -n "$1" ] && [ "$1" = "container_tool" ] ; then
              arg=$(echo "$@" | sed "s|^$1||g")
              container_tool $arg
          fi
          '';
      };
    };

    system.activationScripts.create_docker_networks =
      let dockerBin = "${pkgs.docker}/bin/docker";
      in ''
        if [ -d /var/local/data ]; then
            mkdir -p /var/local/data
        fi

        if [ -d /var/local/data/_system ] ; then
            mkdir -p /var/local/data/_system
        fi

        if [ -d /var/local/db ]; then
            mkdir -p /var/local/db
            ${pkgs.e2fsprogs}/bin/chattr +C /var/local/db
        fi

        if ${pkgs.procps}/bin/pgrep dockerd > /dev/null 2>&1 ; then
            ${dockerBin} network inspect proxy > /dev/null || ${dockerBin} network create proxy --subnet 172.19.0.0/18
            ${dockerBin} network inspect services >/dev/null || ${dockerBin} network create services --subnet 172.19.128.0/18
            ${dockerBin} network inspect socket-proxy >/dev/null || ${dockerBin} network create socket-proxy --subnet 172.19.192.0/18
        fi
      '';

    users.groups = { docker = { }; };

    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = false;
        logDriver = "local";
        storageDriver = docker_storage_driver;
      };

      oci-containers.backend = mkDefault "docker";
    };

    systemd.services = mapAttrs' (n: v: nameValuePair "docker-${n}" (mkService n v)) containercfg // {
      # TODO OPTION Auto create docker networks
      #"docker-networks" = rec {
      #  after = [ "docker.service" "docker.socket" ];
      #  requires = after;
      #  serviceConfig = {
      #    Type = "oneshot";
      #    ExecStart = map (
      #      n: ''${pkgs.bash}/bin/sh -c "${pkgs.docker}/bin/docker network inspect ${escapeShellArg n} > /dev/null || \
      #                ${pkgs.docker}/bin/docker network create ${escapeShellArg n}"''
      #    ) (unique (flatten (mapAttrsToList (_: c: c.networks) containercfg)));
      #  };
      #};
    };
  };
}

