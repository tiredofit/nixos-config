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

Get your installer disc booted up and your disks partitioned. Once you have your partitions created and subvolumes mounted then we can continue..

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

### Deploy Script

A deployment script is included that handles the full lifecycle of NixOS hosts. It can be used interactively via menus or directly from the command line.

#### Prerequisites

- A working Nix installation (preferably NixOS)
- `git`, `age`, `ssh-to-age`, `sops`, `yq`

#### Quick Reference

```
./deploy                                          # Interactive menu mode
./deploy list                                     # List all hosts with status
./deploy create <host> [options]                  # Create new host config
./deploy update <host> [ip]                       # Update existing host
./deploy install <host> <ip>                      # Fresh install (resumable on failure)
./deploy flake update                             # Update flake.lock
./deploy flake upgrade                            # Upgrade running NixOS system
./deploy secrets rekey <all|common|users|host>    # Rekey SOPS secrets
```

#### Global Options

These can be passed before the command and apply to `update` and `install`:

| Option              | Description                                            |
| ------------------- | ------------------------------------------------------ |
| `--remote-build`    | Evaluate locally, build derivations on the remote host |
| `--local-build`     | Build locally and copy result to remote (default)      |
| `--user <username>` | SSH username (default: current user)                   |
| `--ssh-key <path>`  | Path to SSH private key                                |
| `--ssh-port <port>` | SSH port (default: 22)                                 |
| `--reboot`          | Reboot remote host after install                       |
| `--no-reboot`       | Don't reboot after install                             |
| `--debug`           | Verbose output                                         |

#### Creating Hosts

Create a new host configuration without going through the menus:

```
./deploy create myhost --role server --ip 10.0.0.5/24 --gateway 10.0.0.1 --mac aa:bb:cc:dd:ee:ff
./deploy create myvm --role vm --no-encryption --cpu intel --packages stable
```

| Option                               | Description                                                                 |
| ------------------------------------ | --------------------------------------------------------------------------- |
| `--role <role>`                      | `server`, `desktop`, `laptop`, `kiosk`, `minimal`, `vm` (default: `server`) |
| `--ip <ip/mask>`                     | Static IP with subnet mask (eg `10.0.0.5/24`)                               |
| `--gateway <ip>`                     | Network gateway                                                             |
| `--mac <addr>`                       | Network interface MAC address                                               |
| `--cpu <type>`                       | `amd` or `intel` (default: `amd`)                                           |
| `--packages <channel>`               | `stable` or `unstable` (default: `unstable`)                                |
| `--encryption / --no-encryption`     | Full disk encryption (default: on)                                          |
| `--impermanence / --no-impermanence` | Ephemeral root filesystem (default: on)                                     |
| `--raid / --no-raid`                 | RAID array support (default: off)                                           |

#### Updating Hosts

```
./deploy update exmamplehost                           # Auto-resolves IP from config/DNS
./deploy update examplehost 10.0.0.5                  # Explicit IP
./deploy --remote-build update examplehost            # Evaluate locally, build on remote
./deploy --user root --ssh-port 2222 update examplehost
```

With `--remote-build`, flake evaluation and input resolution still happens locally, but the actual Nix derivation builds run on the remote host via `nixos-rebuild --build-host`. This helps when the remote has better CPU/cache access, but won't eliminate local input fetching since flake evaluation requires it.

#### Fresh Installs

Installs use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) and handle SSH key generation, AGE/SOPS secrets setup, and disk partitioning via disko.

```
./deploy install myhost 10.0.0.5
./deploy --remote-build install myhost 10.0.0.5
```

If an install fails partway through, the deploy state is saved to `hosts/<host>/.deploy-state` (gitignored). Re-running the same command will offer to resume from where it left off, skipping already completed steps like key generation and secrets setup. On successful install the state file is automatically cleaned up.

#### Listing Hosts

```
$ ./deploy list
HOST            ROLE       IP                        ENCRYPT  IMPERM
----            ----       --                        -------  ------
host1          server     -                         -        -
host2          server     10.10.10.10/24            false    -
host3          server     142.124.142.142/32        true     true
host4          laptop     -                         -        -
host5          laptop     -                         true     true
host6          server     -                         false    true
host7          server     -                         false    true
```

# License

Do you what you'd like and I hope that this inspires you for your own configurations as many others have myself attribution would be appreciated.
