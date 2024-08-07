{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.boot.kernel;
in
  with lib;
{
  options = {
    host.feature.boot.kernel = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = "Enables Kernel management via these options";
      };
      boot = mkOption {
        default = true;
        type = types.bool;
        description = "Whether to enable the Linux kernel. This is useful for systemd-like containers which do not require a kernel.";
      };
      modules = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "The set of kernel modules to be loaded in the second stage of the boot process";
      };
      modulesBlacklist = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of names of kernel modules that should not be loaded automatically by the hardware probing code.";
      };
      package = mkOption {
        default = "latest";
        type = types.str;
        description = "Kernel package";
      };
      parameters = mkOption {
        type = types.listOf (types.strMatching ''([^"[:space:]]|"[^"]*")+'' // {
          name = "parameters";
          description = "string, with spaces inside double quotes";
        });
        default = [];
        description = "Parameters added to the kernel command line.";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      kernel = {
        enable = cfg.boot;
        ## TODO Bring over sysctl
      };

      blacklistedKernelModules = [] ++ cfg.modulesBlacklist;
      kernelModules = [] ++ cfg.modules;
      kernelPackages = pkgs.linuxPackages_latest; ## TODO This should read the value of package pkgs.linuxPackages_${cfg.package} somehow
      kernelParams = [] ++ cfg.parameters;
    };
  };
}
