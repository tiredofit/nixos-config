{ config, lib, pkgs, ... }:

## These options are very similar to config.virtualisation.oci-containers
## The difference here is that it is docker specific, and allows for multiple networks
## to be called, which is not the case with present day 23.11 options

with lib;
let
  cfg = config.host.feature.virtualization.containers;
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
      after = [ "docker.service" "docker.socket" "docker-networks.service" ]
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

  options.host.feature.virtualization.containers = mkOption {
    default = {};
    type = types.attrsOf (types.submodule containerOptions);
    description = "Docker containers to run as systemd services.";
  };

  config = mkIf (cfg != {}) {

    systemd.services = mapAttrs' (n: v: nameValuePair "docker-${n}" (mkService n v)) cfg // {
      "docker-networks" = rec {
        after = [ "docker.service" "docker.socket" ];
        requires = after;

        serviceConfig = {
          Type = "oneshot";
          ExecStart = map (
            n: ''${pkgs.bash}/bin/sh -c "${pkgs.docker}/bin/docker network inspect ${escapeShellArg n} > /dev/null || \
                      ${pkgs.docker}/bin/docker network create ${escapeShellArg n}"''
          ) (unique (flatten (mapAttrsToList (_: c: c.networks) cfg)));
        };
      };
    };

    virtualisation.docker.enable = true;
  };
}