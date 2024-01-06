# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disk-config.nix
    ];

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.loader.grub = {
    devices = [ "/dev/disk/by-id/nvme-SAMSUNG_MZQLB1T9HAJR-00007_S439NC0R300444" "/dev/disk/by-id/nvme-SAMSUNG_MZQLB1T9HAJR-00007_S439NC0R303530" ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  fileSystems."/" = {
    device = "zpool/root";
    fsType = "zfs";
    neededForBoot = true;
  };

  networking = {
    hostName = "mich";
    hostId = "e3e9d999";

    interfaces.eth0.ipv4.addresses = [ {
      address = "162.55.86.82";
      prefixLength = 26;
    } ];

    defaultGateway = "162.55.86.65";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsyOEBBAQsu8xdEHcSmULhcRj+81KPu5nO2wUwJ3u0WLF740HQniknIvGc0on+1i6+6UJMDTwWOFrevftq9y1KextGLEOb1CS1ZGt/bu6a8FjJAhxnwGdnU3T1cFxUHZJDQD0AEZ5nLO29K2X8HRIGFY/Bsl/wupRsW1wRAs83QMJlu/O962Qcai1z2CkDakvzQ6R3/y6GLE0uRqGHCZOPzpwts3KNGah3EN9JUoUX5xxWiWUnT/Mmb+OcM96WkxqwXED4DuVYuP0vQDRHsDX3ocF6458tKrEg4oYropszIaGr5hkTuZ1JiTt7J8rzFqxVAmhBPXsGMgtC8az7nbDkeSFC6E+zcs7gZy/qTryIVukztupohsZ3xVBwCsKiGaI1NqlXSXALn7uq+wuk7baqChOm6fHXdZTGad1GInQPEznfvIzaKsjdQQnwtbAUTq3tMLwWSH19fBl0mITsKAdZi3+u/mqsEO2YuV+Y69eLoTDUgnCTaTDxlm99xbCfpEU= boet@Boets-Air.home.bo0tzz.me"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    tmux
    git
  ];

  services.openssh.enable = true;

  system.stateVersion = "24.05";

}
