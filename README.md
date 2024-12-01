#  NixOS Configurations

Here are my [NixOS](https://nixos.org/) configurations.
I'm using this for consistent configuration and portability from machine to machine with a small amount of changes (usually disks, partitions, or hardware changes)

- I ~blew~spent the summer of 2023 moving into this configuration after waving a fond farewell to near 2 decades of running Arch Linux. This, as with life, is still WIP. I documented the process on the [Tired of IT! NixOS](https://notes.tiredofit.ca/books/linux/chapter/nixos) chapter on my website.

## Tree Structure

- `flake.nix`: Entrypoint for NixOS configurations.
- `hosts`: Host Configurations
  - `common`: Shared configurations consumed by all hosts.
    - `secrets`: Secrets that are available to all users
  - `<host_a>`: "host_a" specific hardware and host configuration
    - `secrets`: Secrets that are specific to the 'host_a' host
  - `...`: And so on as above with other hosts
- `lib`: Helpers, functions, libraries and timesavers
- `overlays`: Ammendments and updates to packages that exist in the nix ecosphere
- `pkgs`: Custom packages, services, scripts that are specific to this installation
- `users`: Individual User folders

## Usage

### Manual approach

Get your installer disc booted up and your disks partitioned. I took notes on how I did an install with [BTRFS and encryption on my website](https://notes.tiredofit.ca/books/linux/page/installing-nixos-encrypted-btrfs-impermanance). Once you have your partitions created and subvolumes mounted then we can continue..

- Generate your `hardware-configuration.nix` file.

```
nixos-generate-config --root /mnt --file /tmp
```

- Go ahead and clone this repository.

```
nix-shell -p git nixFlakes
git clone https://github.com/tiredofit/nixos-config.git /mnt/etc/nixos
```

- Either create a new host entry in `flake.nix` and add associated bits to the `hosts` folder or modify one of the existing hosts `hardware-configuration.nix` with what you generated above. That's kinda janky, but it'll get you started..

- Install your new NixOS system

```
nixos-install --root /mnt --flake /mnt/etc/nixos#<host>
```

### Optimized deployment via script

- Use the included deployment script on an Arch or NixOS system to:
  - Add remove new hosts and templates
  - Update Flake
  - Update running system
  - Generate SSH Key and AGE keys per host
  - Update host / repository secrets
  - Remotely install a new system based on configuration via SSH
  - Build locally and remotely update an in place system via SSH

### Configuring a system

# License

Do you what you'd like and I hope that this inspires you for your own configurations as many others have myself attribution would be appreciated.
