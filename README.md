# nixos-config

Personal NixOS configuration

## Symbolic Linking 

For convenience, it's better if you just make symbolic links so that there would only be one source of truth.

> **NOTE**: I noticed that using relative paths don't work for source, so use absolute paths instead!

### NixOS Configuration

``` sh
ln -s /path/to/dotfiles/configuration.nix /etc/nixos/configuration.nix
ln -s /path/to/dotfiles/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
```

### `direnv`

``` sh
ln -s /path/to/dotfiles/config/direnv/.direnvrc ~/.direnvrc
```

### `doom-emacs`

``` sh
ln -s /path/to/dotfiles/config/doom ~/.doom.d
```

## Installing NixOS

### Partitions

> **NOTE**: This just serves as my notes. Doesn't actually teach you how to install it for your specific use case. Check the official guide [here](https://nixos.org/manual/nixos/stable/index.html#sec-installation). I basically took parts of it!

> **NOTE**: Ignore anything before `$` and `$` itself in the command line. Don't type out `$`, and also don't bother typing `root$`.

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

3. Add the root partition. This will fill the disk except for the end part, where the swap will live, and the space left in front (512MiB) which will be used by the boot partition.

To avoid the warning about it not being properly aligned, compute the percentage needed to get 8GiB. e.g if the disk you're using is 512GiB, 8 / 512 = 0.015625, or 1.5625%.

```sh
root$ parted /dev/sdb -- mkpart primary 512MiB -1.5625%
```

4. Next, add a swap partition. The size required will vary according to needs. I'll be using 8GiB like the previous step.

```sh
root$ parted /dev/sdb -- mkpart primary linux-swap -1.5625% 100%
```

5. Finally, the boot partition. NixOS by default uses the ESP (EFI system partition) as its /boot partition. It uses the initially reserved 512MiB at the start of the disk. 

```sh
root$ parted /dev/sdb -- mkpart ESP fat32 1MiB 512MiB
root$ parted /dev/sdb -- set 3 esp on
```

### Formatting

```sh
root$ mkfs.ext4 -L nixos /dev/sdb1
root$ mkswap -L swap /dev/sdb2
root$ mkfs.fat -F 32 -n boot /dev/sdb3
```

### Installing

```sh
root$ mount /dev/disk/by-label/nixos /mnt
root$ mkdir -p /mnt/boot
root$ mount /dev/disk/by-label/boot /mnt/boot
root$ nixos-generate-config --root /mnt

```
