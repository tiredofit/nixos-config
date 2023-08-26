{
host_feature_boot-efi = import ./feature/boot-efi.nix;
host_feature_boot-graphical = import ./feature/boot-graphical.nix;
host_feature_cross_compilation = import ./feature/cross_compilation.nix;
host_feature_powermanagement = import ./feature/power_management.nix;
host_feature_virtualization-docker = import ./feature/virtualization-docker.nix;
host_feature_virtualization-flatpak = import ./feature/virtualization-flatpak.nix;
host_feature_virtualization-virtd = import ./feature/virtualization-virtd.nix;

host_filesystem_btrfs = import ./filesystem/btrfs.nix;
host_filesystem_encryption = import ./filesystem/encryption.nix;
host_filesystem_impermanence = import ./filesystem/impermanence.nix;

host_hardware_bluetooth = import ./hardware/bluetooth.nix;
host_hardware_printing = import ./hardware/printing.nix;
host_hardware_raid = import ./hardware/raid.nix;
host_hardware_wireless = import ./hardware/wireless.nix;

host_service_docker_container_manager= import ./service/docker_container_manager.nix;
host_service_vscode_server= import ./service/vscode_server.nix;
}