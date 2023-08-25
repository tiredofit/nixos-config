{
host_feature_boot-efi = import ./feature/boot-efi.nix;
host_feature_cross_compilation = import ./feature/cross_compilation.nix;
host_feature_btrfs = import ./feature/btrfs.nix;
host_feature_encryption = import ./feature/encryption.nix;
host_feature_impermanence = import ./feature/impermanence.nix;
host_feature_powermanagement = import ./feature/power_management.nix;

host_feature_virtualization-docker = import ./feature/virtualization-docker.nix;
host_feature_virtualization-flatpak = import ./feature/virtualization-flatpak.nix;
host_feature_virtualization-virtd = import ./feature/virtualization-virtd.nix;

host_hardware_bluetooth = import ./hardware/bluetooth.nix;
host_hardware_printing = import ./hardware/printing.nix;
host_hardware_raid = import ./hardware/raid.nix;
host_hardware_wireless = import ./hardware/wireless.nix;

host_service_docker_container_manager= import ./service/docker_container_manager.nix;
}