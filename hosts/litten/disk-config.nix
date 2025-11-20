{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          atime = "off";

          # Compression
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";

          # Encryption
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          #keylocation = "file:///tmp/secret.key";
          keylocation = "prompt";
        };
        options.ashift = "12";
        datasets = {
          "root" = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "false";
            mountpoint = "/";
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot/root@blank$' | zfs snapshot zroot/root@blank";
          };
          "root/nix" = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "false";
            mountpoint = "/nix";
          };
          "root/home" = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "true";
            mountpoint = "/home";
          };
          "root/persist" = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "true";
            mountpoint = "/persist";
          };
          "root/media" = {
            type = "zfs_fs";
            options.recordsize = "1M";
            options."com.sun:auto-snapshot" = "true";
            mountpoint = "/media";
          };
        };
      };
    };
  };
}
