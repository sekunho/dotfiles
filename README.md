# dotfiles

Config for all the things

## `ichi`

### Symbolic Linking

For convenience, it's better if you just make symbolic links so that there would
only be one source of truth.

> **NOTE**: I noticed that using relative paths don't work for source, so use
> absolute paths instead!

### NixOS Configuration

``` sh
ln -s /path/to/dotfiles/configuration.nix /etc/nixos/configuration.nix
ln -s /path/to/dotfiles/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
```

##### `direnv`

``` sh
ln -s /path/to/dotfiles/config/direnv/.direnvrc ~/.direnvrc
```

#### `doom-emacs`

``` sh
ln -s /path/to/dotfiles/config/doom ~/.doom.d
```

### Installing NixOS

#### Partitions

> **NOTE**: This just serves as my notes. Doesn't actually teach you how to
> install it for your specific use case. Check the official guide
> [here](https://nixos.org/manual/nixos/stable/index.html#sec-installation).
> I basically took parts of it!

> **NOTE**: Ignore anything before `$` and `$` itself in the command line.
> Don't type out `$`, and also don't bother typing `root$`.

0. Check which disk you would like to install NixOS in.

```sh
$ parted --list

...

Model: ATA Samsung SSD 860 (scsi)
Disk /dev/sdb: 500GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt

...
```

In my case it's `Disk /dev/sdb`, so I'll be using `/dev/sdb`.

1. Run root shell

```sh
$ sudo -s
root$
```

2. Create partition table

```sh
root$ parted /dev/sdb -- mklabel gpt
```

3. Add the root partition. This will fill the disk except for the end part,
where the swap will live, and the space left in front (512MiB) which will be
used by the boot partition.

To avoid the warning about it not being properly aligned, compute the
percentage needed to get 8GiB. e.g if the disk you're using is 512GiB,
8 / 512 = 0.015625, or 1.5625%.

```sh
root$ parted /dev/sdb -- mkpart primary 512MiB -1.5625%
```

4. Next, add a swap partition. The size required will vary according to needs.
I'll be using 8GiB like the previous step.

```sh
root$ parted /dev/sdb -- mkpart primary linux-swap -1.5625% 100%
```

5. Finally, the boot partition. NixOS by default uses the ESP (EFI system
partition) as its /boot partition. It uses the initially reserved 512MiB at
the start of the disk.

```sh
root$ parted /dev/sdb -- mkpart ESP fat32 1MiB 512MiB
root$ parted /dev/sdb -- set 3 esp on
```

#### Formatting

```sh
root$ mkfs.ext4 -L nixos /dev/sdb1
root$ mkswap -L swap /dev/sdb2
root$ mkfs.fat -F 32 -n boot /dev/sdb3
```

#### Installing

```sh
root$ mount /dev/disk/by-label/nixos /mnt
root$ mkdir -p /mnt/boot
root$ mount /dev/disk/by-label/boot /mnt/boot
root$ nixos-generate-config --root /mnt
```

## Other machines

### Creating a DigitalOcean image

`nix-build ./image.nix` creates a file `result/nixos.qcow2.gz` which can be
uploaded as a custom image on DO.

### Secrets management

Using `agenix` for managing secrets.

#### Before applying machine config

`ssh-agent`, ssh keys, and the secrets all have to exist in the server before
applying any configuration than uses `agenix`.

Example for `mew`:

```sh
# Copy SSH key pair
scp -r ~/.ssh/id_mew* root@<SERVER_IP>:/root/.ssh/

# Copy secrets
scp -r secrets root@<SERVER_IP>:/root/

nixos-rebuild switch \
  --flake .#mew \
  --target-host root@<SERVER_IP> \
  --build-host localhost
```

It should show something like this:

```
warning: Git tree '/shared/System/dotfiles' is dirty
building the system configuration...
warning: Git tree '/shared/System/dotfiles' is dirty
copying 5 paths...
copying path '/nix/store/biclaxkfi318vlbsiv548y3p2mp5q9ha-unit-script-tailscale-autoconnect-start' to 'ssh://root@<SERVER_IP>'...
copying path '/nix/store/06sppjffcviai05cp9d0mp2iaiakpv0b-unit-tailscale-autoconnect.service' to 'ssh://root@<SERVER_IP>'...
copying path '/nix/store/b1mlmlalacd374g1cr1pzmcjfkd5dkp4-system-units' to 'ssh://root@<SERVER_IP>'...
copying path '/nix/store/mpnsfmwpaw940d346hpf4nml2ppcm26h-etc' to 'ssh://root@<SERVER_IP>'...
copying path '/nix/store/sz0kgb1wipfncyvs2siy93qs86l9bfpx-nixos-system-unnamed-22.05.20221024.6107f97' to 'ssh://root@<SERVER_IP>'...
updating GRUB 2 menu...
activating the configuration...
[agenix] creating new generation in /run/agenix.d/3
[agenix] decrypting secrets...
decrypting '/root/secrets/emojiedDBCACert.age' to '/run/agenix.d/3/emojiedDBCACert'...
decrypting '/root/secrets/emojiedDBPassword.age' to '/run/agenix.d/3/emojiedDBPassword'...
decrypting '/root/secrets/tailscaleKey.age' to '/run/agenix.d/3/tailscaleKey'...
[agenix] symlinking new secrets to /run/agenix (generation 3)...
[agenix] removing old secrets (generation 2)...
[agenix] chowning...
setting up /etc...
reloading user units for root...
setting up tmpfiles
```

#### Adding a new key

Say you want to add a new public key to those who can read the secrets. Let us
assume you've already created the SSH key pair.

1. Add the public key to `secrets/secrets.nix`.
2. Re-key the keys `cd secrets && agenix -r`

Make sure the key pair is present in the machine that will read the secret.
