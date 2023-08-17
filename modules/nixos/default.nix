{
  hostoption_bluetooth = import ./bluetooth.nix;
  hostoption_boot-efi = import ./boot-efi.nix;
  hostoption_btrfs = import ./btrfs.nix;
  hostoption_encryption = import ./encryption.nix;
  hostoption_impermanence = import ./impermanence.nix;
  hostoption_power_management = import ./power_management.nix;
  hostoption_printing = import ./printing.nix;
  hostoption_raid = import ./raid.nix;
  hostoption_wireless = import ./wireless.nix;
}