{
host-feature-authentication-sssd = import ./feature/authentication-sssd.nix;
host-feature-boot-efi = import ./feature/boot-efi.nix;
host-feature-boot-graphical = import ./feature/boot-graphical.nix;
host-feature-cross_compilation = import ./feature/cross_compilation.nix;
host-feature-gaming = import ./feature/gaming.nix;
host-feature-gaming-steam = import ./feature/gaming-steam.nix;
host-feature-power_management = import ./feature/power_management.nix;
host-feature-secrets = import ./feature/secrets.nix;
host-feature-s3ql = import ./feature/s3ql.nix;
host-feature-virtualization-docker = import ./feature/virtualization-docker.nix;
host-feature-virtualization-flatpak = import ./feature/virtualization-flatpak.nix;
host-feature-virtualization-virtd = import ./feature/virtualization-virtd.nix;

host-filesystem-btrfs = import ./filesystem/btrfs.nix;
host-filesystem-encryption = import ./filesystem/encryption.nix;
host-filesystem-impermanence = import ./filesystem/impermanence.nix;

host-hardware-bluetooth = import ./hardware/bluetooth.nix;
host-hardware-graphics = import ./hardware/graphics.nix;
host-hardware-printing = import ./hardware/printing.nix;
host-hardware-raid = import ./hardware/raid.nix;
host-hardware-wireless = import ./hardware/wireless.nix;

host-network-firewall_fail2ban = import ./network/firewall-fail2ban.nix;
host-network-firewall_opensnitch = import ./network/firewall-opensnitch.nix;
host-network-vpn_tailscale = import ./network/vpn-tailscale.nix;

host-service-docker_container_manager = import ./service/docker_container_manager.nix;
host-service-eternal_terminal = import ./service/eternal_terminal.nix;
host-service-vscode_server = import ./service/vscode_server.nix;
}