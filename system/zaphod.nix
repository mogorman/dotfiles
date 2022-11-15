{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./common.nix
    ../secrets/secrets.nix
    ../services/ssh.nix
    ../users/mog.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # HARDWARE CONFIG
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sdhci_pci"
    "rtsx_usb_sdmmc"
    "igb"
  ];

  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/5ac1fc24-9691-44f8-9e12-c08e1f137637";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/4006-27C7";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/fc5d67c1-7daf-4dba-998b-5ff64ad79a11"; }
    ];


  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # high-resolution display
  hardware.video.hidpi.enable = true;
  security.pam.enableSSHAgentAuth = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    git-crypt
    gnupg
    pinentry
    nmap
  ];
  hardware.nitrokey.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
 programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
    pinentryFlavor = "curses";
 };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    extraConfig = ''
       StreamLocalBindUnlink yes
    '';
  };

  services.udev.extraRules = ''
    ATTR{idVendor}=="20a0", MODE="0660", GROUP="users"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="00:e2:69:5a:40:45", NAME="eth0"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="00:e2:69:5a:40:46", NAME="eth1"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="00:e2:69:5a:40:47", NAME="eth2"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="00:e2:69:5a:40:48", NAME="eth3"

  '';

  networking = {
    hostName = "zaphod";
    useNetworkd = true;
    useDHCP = false;
  };

systemd.network = {
    netdevs = {
      "10-bond0" = {
        netdevConfig = {
          Kind = "bond";
          Name = "bond0";
        };
        bondConfig = {
          Mode = "802.3ad";
          TransmitHashPolicy = "layer3+4";
        };
      };
    };
    networks = {
      "30-eth1" = {
        matchConfig.Name = "eth1";
        networkConfig.Bond = "bond0";
      };

      "30-eth2" = {
        matchConfig.Name = "eth2";
        networkConfig.Bond = "bond0";
      };

      "30-eth3" = {
        matchConfig.Name = "eth3";
        networkConfig.Bond = "bond0";
      };

      "40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig = {
          RequiredForOnline = "carrier";
        };
        networkConfig.LinkLocalAddressing = "no";
      };
      "40-eth0" = {
         enable = true;
         matchConfig.Name = "eth0";
         networkConfig = {
           DHCP = "yes";
           DNSSEC = "yes";
           DNSOverTLS = "yes";
           DNS = [ "1.1.1.1" "1.0.0.1" ];
         };
         dhcpV4Config.RouteMetric = 1024;
      };
    };
  };
}
