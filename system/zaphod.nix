{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./common.nix
    ../secrets/secrets.nix
    ../services/ssh.nix
    ../services/nfs_server.nix
    ../services/dnsmasq.nix
    ../services/avahi.nix
    ../users/mog.nix
    ../users/joe.nix
    ../users/media.nix
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

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # high-resolution display
  hardware.video.hidpi.enable = true;
  security.pam.enableSSHAgentAuth = true;

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

  fileSystems."/export/drive_1" =
    { device = "/dev/mapper/drive_1";
      fsType = "ext4";
      options = [ "nofail" "noauto" ];
    };

  fileSystems."/export/drive_2" =
    { device = "/dev/mapper/drive_2";
      fsType = "ext4";
      options = [ "nofail" "noauto" ];
    };

  fileSystems."/export/drive_3" =
    { device = "/dev/mapper/drive_3";
      fsType = "ext4";
      options = [ "nofail" "noauto" ];
    };

  fileSystems."/export/drive_4" =
    { device = "/dev/mapper/drive_4";
      fsType = "ext4";
      options = [ "nofail" "noauto" ];
    };

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
    iperf
    speedtest-cli
    screen
    cryptsetup
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
  '';

  services.resolved = {
    enable = false;
  };

  networking = {
    enableIPv6 = false;
    hostName = "zaphod";
    useDHCP = false;
    firewall.enable = false;
    useNetworkd = true;

    hosts = {
      "127.0.0.1" = [ "zaphod" ];
      "10.0.2.1" = [ "home-assistant.local" "random.local" ];
    };

    vlans = {
      iot0 = {
        id = 100;
        interface = "bond0";
      };
      guest0 = {
        id = 10;
        interface = "bond0";
      };
      lan0 = {
        id = 2;
        interface = "bond0";
      };
      lan1 = {
        id = 3;
        interface = "bond0";
      };

    };

    interfaces = {
      eth0.useDHCP = true;
      bond0.useDHCP = false;

      lan0.ipv4.addresses = [{
        address = "10.0.2.1";
        prefixLength = 24;
      }];
      lan1.ipv4.addresses = [{
        address = "10.0.3.1";
        prefixLength = 24;
      }];
      guest0.ipv4.addresses = [{
        address = "10.0.10.1";
        prefixLength = 24;
      }];
      iot0.ipv4.addresses = [{
        address = "10.0.100.1";
        prefixLength = 24;
      }];
    };
    nat = {
      enable = true;
      internalIPs = [
        "10.0.2.0/24"
        "10.0.2.0/24"
        "10.0.10.0/24"
        "10.0.100.0/24"
        "10.0.42.0/24"
      ];
      internalInterfaces = [ "lan0" "lan1" "guest0" "iot0" ];
      externalInterface = "eth0";
      forwardPorts = [ ];
    };
  };

  systemd.network = {
    wait-online.anyInterface = true;
    links = {
      "10-eth0" = { matchConfig.MACAddress = "00:e2:69:5a:40:45"; linkConfig.Name = "eth0"; }; 
      "10-eth1" = { matchConfig.MACAddress = "00:e2:69:5a:40:46"; linkConfig.Name = "eth1"; };
      "10-eth2" = { matchConfig.MACAddress = "00:e2:69:5a:40:47"; linkConfig.Name = "eth2"; };
      "10-eth3" = { matchConfig.MACAddress = "00:e2:69:5a:40:48"; linkConfig.Name = "eth3"; };
    };
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
        vlan = [ "lan0" "lan1" "guest0" "iot0" ];
      };
    };
  };
}
