 {config, lib, pkgs, ...}:

let
  cfg = config.host.filesystem.encryption;
in
  with lib;
{
  options = {
    host.filesystem.encryption = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Encrypt Filesystem using LUKS";
      };
      encrypted-partition = mkOption {
        type = types.str;
        default = "pool0_0";
        description = "Encrypted LUKS container to mount";
      };
      ssh = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Unlock via SSH on bootup";
        };
        authorizedKeys = mkOption {
          type = types.listOf types.str;
          default = [];
          defaultText = literalExpression "config.users.users.root.openssh.authorizedKeys.keys";
          description = lib.mdDoc ''
            Authorized keys for the root user on initrd.
          '';
        };
        hostKeys = mkOption {
          default = [];
          type = types.listOf (types.either types.str types.path);
          example = [
            "/etc/secrets/initrd/ssh_host_rsa_key"
            "/etc/secrets/initrd/ssh_host_ed25519_key"
          ];
          description = lib.mdDoc ''
            Specify SSH host keys to import into the initrd.

            To generate keys, use
            {manpage}`ssh-keygen(1)`
            as root:

            ```
            ssh-keygen -t rsa -N "" -f /etc/secrets/initrd/ssh_host_rsa_key
            ssh-keygen -t ed25519 -N "" -f /etc/secrets/initrd/ssh_host_ed25519_key
            ```

            ::: {.warning}
            Unless your bootloader supports initrd secrets, these keys
            are stored insecurely in the global Nix store. Do NOT use
            your regular SSH host private keys for this purpose or
            you'll expose them to regular users!

            Additionally, even if your initrd supports secrets, if
            you're using initrd SSH to unlock an encrypted disk then
            using your regular host keys exposes the private keys on
            your unencrypted boot partition.
            :::
          '';
        };
        networkModule = {
          type = types.listOf types.str;
          default = [];
          example = [ "ixgbe" "r8169" ];
          description = "Kernel module to embed in initrd to allow for network access. Use 'lspci -v' to get the right module";
        };
        port = mkOption {
          default = 22;
          type = with types; port;
          description = "SSH Listen Port";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = mkIf cfg.ssh.enable [
      {
        assertion = (cfg.ssh.authorizedKeys != []);
        message = "You should specify at least one authorized key for initrd SSH";
      }

      {
        assertion = (cfg.ssh.hostKeys != []);
        message = ''
          You must now pre-generate the host keys for initrd SSH.
          See the boot.initrd.network.ssh.hostKeys documentation
          for instructions.
        '';
      }
    ];

    environment.systemPackages =  with pkgs; [
      cryptsetup          # Manipulate LUKS containers
    ];

    boot.initrd = mkIf cfg.ssh.enable {
      availableKernelModules = [ cfg.ssh.networkModule ];
      luks.forceLuksSupportInInitrd = mkForce true;
      network = {
        enable = mkForce true;
        ssh = {
          enable = mkForce true;
          port = cfg.ssh.port;
          authorizedKeys = [ cfg.ssh.authorizedKeys ];
          hostKeys = [ cfg.ssh.hostKeys ];
        };
      };
    };
  };
}
