{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./common.nix
    ../secrets/secrets.nix
    ../services/ssh.nix
    ../services/frigate.nix
    ../services/tubesync.nix
    ../services/mosquitto.nix
    ../services/zigbee2mqtt.nix
#    ../services/amcrest2mqtt.nix # dahua integration is better
    ../services/mumble.nix
    ../services/postgresql.nix
    ../services/homeassistant.nix
    ../services/media.nix
    ../services/dnsmasq.nix
    ../services/avahi.nix
    ../services/acme.nix
    ../services/nginx.nix
    ../services/audiobookshelf.nix
    ../services/komga.nix
    ../services/samba.nix
    ../services/syncthing.nix
    ../secrets/nathanbox.nix
    ../packages/packages.nix
    ../users/mog.nix
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

  boot.initrd.luks.devices."06tb" = {
    device = "/dev/disk/by-uuid/88c2c241-b24c-4420-881f-be7df6663734";
    preLVM = false;
    allowDiscards = true;
  };
  boot.initrd.luks.devices."04tb" = {
    device = "/dev/disk/by-uuid/07f589a2-3312-4337-8ceb-ff6226b341f3";
    preLVM = false;
    allowDiscards = true;
  };
  boot.initrd.luks.devices."16tb" = {
    device = "/dev/disk/by-uuid/2eba0bac-7bf4-4207-a695-78e064c57665";
    preLVM = false;
    allowDiscards = true;
  };
  boot.initrd.luks.devices."10tb" = {
    device = "/dev/disk/by-uuid/8702cb62-ad8f-4925-9595-e6c30bbb501a";
    preLVM = false;
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

    echo "tor: starting tor"
    tor -f ${torRc} --verify-config
    tor -f ${torRc} &
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/41c0df27-00a5-40ee-9334-bb5737a0a124";
    fsType = "ext4";
  };

  fileSystems."/external/06tb" = {
    device = "/dev/disk/by-uuid/d40907e4-0ca8-44bc-b145-bf191e499c7c";
    fsType = "ext4";
  };
  fileSystems."/external/04tb" = {
    device = "/dev/disk/by-uuid/c8f67343-9418-4c66-acf7-7d62f1b1acd2";
    fsType = "ext4";
  };
  fileSystems."/external/16tb" = {
    device = "/dev/disk/by-uuid/e79fcb6d-d723-4b9b-8d65-c86d6d89875b";
    fsType = "ext4";
  };
  fileSystems."/external/10tb" = {
    device = "/dev/disk/by-uuid/a6a7cdb4-c335-403c-b02e-21679f172e16";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C833-35FD";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/d9d19b7c-2abc-415b-95e5-3d4410f490f0"; }];

  # high-resolution display
  hardware.video.hidpi.enable = true;
  # HARDWARE CONFIG 
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.default.forwarding" = 1;
  };

  networking = {
    enableIPv6 = false;
    hostId = "72209696";
    hostName = "random";
    useDHCP = false;

    hosts = {
      "127.0.0.1" = [ "random" ];
      "10.0.2.1" = [ "home-assistant.local" "random.local" ];
    };

    vlans = {
      iot0 = {
        id = 100;
        interface = "eth1";
      };
      guest0 = {
        id = 10;
        interface = "eth1";
      };
      lan0 = {
        id = 2;
        interface = "eth1";
      };
      lan1 = {
        id = 3;
        interface = "eth1";
      };

    };

    interfaces = {
      eth0 = { useDHCP = true; };
      eth1.useDHCP = false;

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

    #  nat.enable = false;
    #  firewall.enable = false;
    #  nftables = {
    #    enable = true;
    #    ruleset = ''
    #      table ip filter {
    #        # enable flow offloading for better throughput
    #        flowtable f {
    #          hook ingress priority 0;
    #          devices = { eth0, lan0, guest0 };
    #        }
    #
    #        chain output {
    #          type filter hook output priority 100; policy accept;
    #        }
    #
    #        chain input {
    #          type filter hook input priority filter; policy drop;
    #
    #          # Allow trusted networks to access the router
    #          iifname {
    #            "lan0",
    #          } counter accept
    # 
    # #         # Allow trusted networks to access the router
    # #         iifname {
    # #           "guest0",
    # #         } counter accept
    #
    #
    #          # Allow returning traffic from ppp0 and drop everthing else
    #          iifname "eth0" ct state { established, related } counter accept
    #          iifname "eth0" drop
    #        }
    #        
    #        chain forward {
    #          type filter hook forward priority filter; policy drop;
    #
    #          # enable flow offloading for better throughput
    #          ip protocol { tcp, udp } flow offload @f
    #
    #          # Allow trusted network WAN access
    #          iifname {
    #                  "lan0",
    #          } oifname {
    #                  "eth0",
    #          } counter accept comment "Allow trusted LAN to WAN"
    #
    #          # Allow established WAN to return
    #          iifname {
    #                  "eth0",
    #          } oifname {
    #                  "lan0",
    #          } ct state established,related counter accept comment "Allow established back to LANs"
    #        }
    #      }
    #
    #      table ip nat {
    #        chain prerouting {
    #          type nat hook output priority filter; policy accept;
    #        }
    #
    #        # Setup NAT masquerading on the ppp0 interface
    #        chain postrouting {
    #          type nat hook postrouting priority filter; policy accept;
    #          oifname "eth0" masquerade
    #        } 
    #      }
    #    '';
    #  };

    #nameservers = [ "4.4.4.4" "8.8.8.8" ];
    nat = {
      enable = true;
      internalIPs = [
        "10.0.2.0/24"
        "10.0.2.0/24"
        "10.0.10.0/24"
        "10.0.100.0/24"
        "10.0.42.0/24"
      ];
      internalInterfaces = [ "lan0" "lan1" "guest0" "iot0" "ve-seedbox" "wg0" ];
      externalInterface = "eth0";
      forwardPorts = [ 
# {
#    destination = "127.0.0.1:1935";
#    proto = "tcp";
#    sourcePort = 1935;
#  }
 ];
    };
    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [ "lo" "lan0" "lan1" "guest0" "docker0" "iot0" ];
      checkReversePath = false; # https://github.com/NixOS/nixpkgs/issues/10101

      extraCommands = ''
        iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eth0 -j MASQUERADE
        iptables -t nat -A POSTROUTING -s 10.0.3.0/24 -o eth0 -j MASQUERADE
        iptables -t nat -A POSTROUTING -s 10.0.10.0/24 -o eth0 -j MASQUERADE
        #BLOCK IOT FROM INTERNET but allow my laptop to access internet
        iptables -A FORWARD -i iot0 -s 10.0.100.30  -j ACCEPT

        iptables -A FORWARD -i iot0 -s 10.0.100.41  -j ACCEPT
        iptables -A FORWARD -i iot0 -s 10.0.100.42  -j ACCEPT
        iptables -A FORWARD -i iot0 -s 10.0.100.72  -j ACCEPT

        iptables -A FORWARD -i iot0 -o eth0 -j REJECT
      '';

      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [   {
    from = 10000;
    to = 20000;
  } ];

      allowedTCPPorts = [
        22 # SSH
        80 # nginx
        443 # nginx
        #        8096 # Jellyfin
        #        8123 # Home assistant
        #        5000 # Frigate
        #        7878 # Radarr
        #        8989 # Sonarr
        #        4848 # tubesync
      ];
      allowedUDPPorts = [
        53 # DNS
        51820 # wireguard main
        51821 # wireguard seed
      ];
    };
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.0.42.1/24" ];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = 51820;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.0.42.0/24 -o eth0 -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.0.42.0/24 -o eth0 -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "${../secrets/wireguard/random_private}";

      peers = [
        # List of allowed peers.
        { # Madrox
          publicKey = "4CUkyO2vfZjZIc+fvsYI3Vg3j1ptFFNvRYyuntgo6UM=";
          allowedIPs = [ "10.0.42.2/32" ];
        }
        { # Mog Phone
          publicKey = "YUZwRf8w/dVPcD+HgYFzZhjluxuDNaxjiNefwtH+Qhc=";
          allowedIPs = [ "10.0.42.3/32" ];
        }
        { # Trillian
          publicKey = "TJQSuFFiBFwZmwaAqBkDQnJgFoLSqqpXWHVLecdk4wE=";
          allowedIPs = [ "10.0.42.4/32" ];
        }

      ];
    };
  };

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
}
