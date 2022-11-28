{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./common.nix
    ../secrets/secrets.nix
    ../services/ssh.nix
    ../services/nfs_server.nix
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
    enable = true;
    fallbackDns = [ "8.8.8.8" "1.1.1.1" ];
  };

  services.unbound = {
    enable = true;
    settings = {
          server = {
            interface = [ "127.0.0.1" "10.0.2.1" "10.0.3.1" "10.0.10.1" "10.0.100.1" ];
            access-control = [ "127.0.0.0/8 allow" 
                               "10.0.2.0/24 allow" 
                               "10.0.2.0/24 allow" 
                               "10.0.10.0/24 allow" 
                               "10.0.100.0/24 allow" 
                             ];
          };
          forward-zone = [
            {
              name = ".";
              forward-addr = [
                "1.1.1.1@853#cloudflare-dns.com"
                "1.0.0.1@853#cloudflare-dns.com"
              ];
              forward-tls-upstream = "yes";
            }
          ];
      stub-zone = let
        stubZone = name: addrs: { name = "${name}"; stub-addr = addrs; };
      in
        [
          (stubZone "zaphod" ["10.0.2.1"])
        ];
        };
  };

  networking = {
    hostName = "zaphod";
    firewall.enable = false;
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "127.0.0.1" ];
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

      "11-lan0" = {
        netdevConfig = { Name = "lan0"; Kind = "vlan"; };
        vlanConfig.Id = 2;
      };

      "11-lan1" = {
        netdevConfig = { Name = "lan1"; Kind = "vlan"; };
        vlanConfig.Id = 3;
      };

      "11-guest0" = {
        netdevConfig = { Name = "guest0"; Kind = "vlan"; };
        vlanConfig.Id = 10;
      };
      "11-iot0" = {
        netdevConfig = { Name = "iot0"; Kind = "vlan"; };
        vlanConfig.Id = 100;
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

     "10-eth0" = {
        enable = true;
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "yes";
#          DNSSEC = "yes";
#          DNSOverTLS = "yes";
          DNS = [ "10.0.2.1" ];
        };
        dhcpV4Config.RouteMetric = 1024;
     };

      "40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig = {
          RequiredForOnline = "carrier";
        };
        networkConfig.LinkLocalAddressing = "no";
        vlan = [ "lan0" "lan1" "guest0" "iot0" ];
      };

      "51-lan0" = {
        matchConfig.Name = "lan0";
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          IPMasquerade = true;
          LinkLocalAddressing = "yes";
          Address = "10.0.2.1/24";
          DNS = [ "10.0.2.1" ];
        };
        dhcpServerConfig = {
          PoolOffset = 100;
          EmitDNS = true;
#          DNS = [ "1.1.1.1" "1.0.0.1" ];
        };
      };

      "52-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          IPMasquerade = true;
          LinkLocalAddressing = "yes";
          Address = "10.0.3.1/24";
        };
        dhcpServerConfig = {
          PoolOffset = 100;
          EmitDNS = true;
 #         DNS = [ "1.1.1.1" "1.0.0.1" ];
        };
      };

      "53-guest0" = {
        matchConfig.Name = "guest0";
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          IPMasquerade = true;
          LinkLocalAddressing = "yes";
          Address = "10.0.10.1/24";
        };
        dhcpServerConfig = {
          PoolOffset = 100;
          EmitDNS = true;
  #        DNS = [ "1.1.1.1" "1.0.0.1" ];
        };
      };

      "54-iot0" = {
        matchConfig.Name = "iot0";
        networkConfig = {
          DHCPServer = true;
          MulticastDNS = true;
          IPMasquerade = true;
          LinkLocalAddressing = "yes";
          Address = "10.0.100.1/24";
        };
        dhcpServerConfig = {
          PoolOffset = 100;
          EmitDNS = true;
   #       DNS = [ "1.1.1.1" "1.0.0.1" ];
        };
      };
    };
  };
}
