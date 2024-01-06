{
  disko.devices = {
    disk = {
      disk1 = {
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZQLB1T9HAJR-00007_S439NC0R300444";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              start = "0";
              end = "1MiB";
              part-type = "primary";
              flags = ["bios_grub"];
            }
            esp = {
              name = "ESP";
              start = "1MiB";
              end = "385MiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zpool";
              };
            }
          };
        };
      };
      disk2 = {
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZQLB1T9HAJR-00007_S439NC0R303530";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              start = "0";
              end = "1MiB";
              part-type = "primary";
              flags = ["bios_grub"];
            }
            esp = {
              name = "ESP";
              start = "1MiB";
              end = "385MiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
              };
            }
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zpool";
              };
            }
          };
        };
      };
    };
    
    zpool = {
      zpool = {
        type = "zpool";
        mode = "mirror";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          mountpoint = "none";
          acltype = "posixacl";
          canmount = "off";
          compression = "zstd";
          dnodesize = "auto";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
        };

        datasets = {
          root = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
          };
          nix = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
          home = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
        };
      };
    };
  };
}
