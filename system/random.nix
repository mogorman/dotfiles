{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./common.nix
    ../secrets/secrets.nix
    ../services/ssh.nix
    ../services/postgresql.nix
    ../services/media.nix
    ../services/nginx.nix
    ../services/acme.nix
    ../secrets/nathanbox.nix
    ../services/audiobookshelf.nix
    ../services/disable_ethernet.nix
#    ../services/frigate.nix
#    ../services/tubesync.nix
#    ../services/mosquitto.nix
#    ../services/zigbee2mqtt.nix
##    ../services/amcrest2mqtt.nix # dahua integration is better
#    ../services/mumble.nix
#    ../services/homeassistant.nix
#    ../services/dnsmasq.nix
#    ../services/avahi.nix
#    ../services/komga.nix
#    ../services/samba.nix
#    ../services/syncthing.nix
#    ../services/reboot_cameras.nix
    ../packages/packages.nix
    ../users/mog.nix
    ../users/joe.nix
    ../users/media.nix
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="apex", MODE="0660", GROUP="users"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="00:e0:4c:02:05:f5", NAME="eth1"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="00:e0:4c:02:05:f4", NAME="eth0"
  '';
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.reusePassphrases = true;
  boot.kernelParams=["i915.enable_guc=3"];
  hardware.enableRedistributableFirmware = true;

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
    "ax88179_178a"
  ];

  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages =
    [ (config.boot.kernelPackages.callPackage ../packages/gasket.nix { }) ];

  boot.initrd.luks.devices.luksroot = {
    device = "/dev/disk/by-uuid/6143d5ea-2cf1-41b8-ab52-da5d6c4b4e86";
    preLVM = true;
    allowDiscards = true;
  };

  boot.initrd.luks.devices.drive_1 = {
    device = "/dev/disk/by-uuid/2eba0bac-7bf4-4207-a695-78e064c57665";
    preLVM = true;
    allowDiscards = true;
  };

  boot.initrd.luks.devices.drive_2 = {
    device = "/dev/disk/by-uuid/261ffed2-dcc2-4f1d-b9c8-7222510bfbb4";
    preLVM = true;
    allowDiscards = true;
  };

  boot.initrd.luks.devices.drive_3 = {
    device = "/dev/disk/by-uuid/8702cb62-ad8f-4925-9595-e6c30bbb501a";
    preLVM = true;
    allowDiscards = true;
  };

  boot.initrd.luks.devices.drive_4 = {
    device = "/dev/disk/by-uuid/88c2c241-b24c-4420-881f-be7df6663734";
    preLVM = true;
    allowDiscards = true;
  };


  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    authorizedKeys = config.mog_keys;
    hostKeys = [
      "${config.dotfiles_dir}/secrets/keys/${config.networking.hostName}_initrd__ssh_host_rsa_key"
      "${config.dotfiles_dir}/secrets/keys/${config.networking.hostName}_initrd__ssh_host_ed25519_key"
    ];
  };

  boot.initrd.secrets = {
    "/etc/tor/onion/bootup" =
      "${config.dotfiles_dir}/secrets/boot_onion"; # maybe find a better spot to store this.
  };

  # copy tor to you initrd
  boot.initrd.extraUtilsCommands = ''
    copy_bin_and_libs ${pkgs.tor}/bin/tor
  '';

  # start tor during boot process
  boot.initrd.network.postCommands = let
    torRc = (pkgs.writeText "tor.rc" ''
      DataDirectory /etc/tor
      SOCKSPort 127.0.0.1:9050 IsolateDestAddr
      SOCKSPort 127.0.0.1:9063
      HiddenServiceDir /etc/tor/onion/bootup
      HiddenServicePort 22 127.0.0.1:22
    '');
  in ''
    echo "tor: preparing onion folder"
    sleep 3
    # have to do this otherwise tor does not want to start
    chmod -R 700 /etc/tor

    echo "make sure localhost is up"
    ip a a 127.0.0.1/8 dev lo
    ip link set lo up

    echo "TRYING TO GET STATIC IP ADDRESS"
    sleep 5
    ifconfig enp0s21f0u3 10.0.2.3 netmask 255.255.255.0 up
    ping -c 10 10.0.2.1
    ping -c 10 10.0.2.1
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    sleep 10

    echo "tor: starting tor"
    tor -f ${torRc} --verify-config
    tor -f ${torRc} &
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/41c0df27-00a5-40ee-9334-bb5737a0a124";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C833-35FD";
    fsType = "vfat";
  };


  fileSystems."/mnt/drive_1" = {
    device = "/dev/mapper/drive_1";
    fsType = "ext4";
  };
  fileSystems."/mnt/drive_2" = {
    device = "/dev/mapper/drive_2";
    fsType = "ext4";
  };
  fileSystems."/mnt/drive_3" = {
    device = "/dev/mapper/drive_3";
    fsType = "ext4";
  };
  fileSystems."/mnt/drive_4" = {
    device = "/dev/mapper/drive_4";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/d9d19b7c-2abc-415b-95e5-3d4410f490f0"; }];

  # high-resolution display
  hardware.video.hidpi.enable = true;
#  networking.wireguard.interfaces = {
#    # "wg0" is the network interface name. You can name the interface arbitrarily.
#    wg0 = {
#      # Determines the IP address and subnet of the server's end of the tunnel interface.
#      ips = [ "10.0.42.1/24" ];
#
#      # The port that WireGuard listens to. Must be accessible by the client.
#      listenPort = 51820;
#
#      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
#      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
#      postSetup = ''
#        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.42.0/24 -o eth0 -j MASQUERADE
#      '';
#
#      # This undoes the above command
#      postShutdown = ''
#        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.42.0/24 -o eth0 -j MASQUERADE
#      '';
#
#      # Path to the private key file.
#      #
#      # Note: The private key can also be included inline via the privateKey option,
#      # but this makes the private key world-readable; thus, using privateKeyFile is
#      # recommended.
#      privateKeyFile = "${../secrets/wireguard/random_private}";
#
#      peers = [
#        # List of allowed peers.
#        { # Madrox
#          publicKey = "4CUkyO2vfZjZIc+fvsYI3Vg3j1ptFFNvRYyuntgo6UM=";
#          allowedIPs = [ "10.0.42.2/32" ];
#        }
#        { # Mog Phone
#          publicKey = "YUZwRf8w/dVPcD+HgYFzZhjluxuDNaxjiNefwtH+Qhc=";
#          allowedIPs = [ "10.0.42.3/32" ];
#        }
#        { # Trillian
#          publicKey = "TJQSuFFiBFwZmwaAqBkDQnJgFoLSqqpXWHVLecdk4wE=";
#          allowedIPs = [ "10.0.42.4/32" ];
#        }
#        { # Tom TV
#          publicKey = "bfHygoBbiFkFFkr68SD2NlPbpTVQbKxnwnhVO63+MSE=";
#          allowedIPs = [ "10.0.42.10/32" ];
#        }
#       { # Blue fire / livingroom frame
#          publicKey = "UfnRPugELsYoWsuFNNjvzJ+IaTxxdkcshvqKQSqG6EM=";
#          allowedIPs = [ "10.0.42.60/32" ];
#        } 
#      ];
#    };
#  };
#
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  programs.gnupg.agent.pinentryFlavor = "curses";
  security.pam.enableSSHAgentAuth = true;

boot.kernel.sysctl = {
  "net.ipv4.ip_forward" = 1;
};

  networking = {
    hostName = "random";
    useNetworkd = true;
    useDHCP = false;
    interfaces.enp0s21f0u3.useDHCP = false;
    nat = {
      enable = true;
      internalInterfaces = [ "docker0" "ve-nathanbox" ];
      externalInterface = "bond0";
    };

    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [ "bond0" "lo" "docker0" "ve-nathanbox" ];
      checkReversePath = false; # https://github.com/NixOS/nixpkgs/issues/10101

      extraCommands = ''
      iptables --flush
      iptables --table nat --flush
      iptables -t nat -A POSTROUTING -o bond0 -j MASQUERADE  
      '';
    };
  };

  systemd.network = {
    wait-online.anyInterface = true;
    links = {
      "11-eth1" = { matchConfig.MACAddress = "00:e0:4c:02:05:f5"; linkConfig.Name = "eth1"; };
      "10-eth0" = { matchConfig.MACAddress = "00:e0:4c:02:05:f4"; linkConfig.Name = "eth0"; };
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
      "30-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig.Bond = "bond0";
      };

      "30-eth1" = {
        matchConfig.Name = "eth1";
        networkConfig.Bond = "bond0";
      };

      "40-bond0" = {
        matchConfig.Name = "bond0";
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
