{ config, lib, pkgs, inputs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./common.nix
    ../services/ssh.nix
    ../services/frigate.nix
    ../services/tubesync.nix
    ../services/mosquitto.nix
    ../services/mumble.nix
    ../services/postgresql.nix
    ../services/homeassistant.nix
    ../services/media.nix
    ../services/dnsmasq.nix
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
  boot.initrd.luks.devices."02tb" = {
    device = "/dev/disk/by-uuid/8651a7c7-006b-45e3-8782-1bf06d415df5";
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
  fileSystems."/external/02tb" = {
    device = "/dev/disk/by-uuid/92cca9f5-e56a-4bf0-82c8-192c73758598";
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
    hostId = "72209696";
    hostName = "random";
    useDHCP = false;

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
    };

    interfaces = {
      eth0.useDHCP = true;
      eth1.useDHCP = false;

      lan0.ipv4.addresses = [{
        address = "10.0.2.1";
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

    #nameservers = [ "4.4.4.4" "8.8.8.8" ];
    nat = {
      enable = true;
      internalIPs = [ "10.0.2.0/24" "10.0.10.0/24" "10.0.100.0/24" ];
      internalInterfaces = [ "lan0" "guest0" "iot0" ];
      externalInterface = "eth0";
      forwardPorts = [ ];
    };
    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [ "lo" "lan0" "guest0" "docker0" "iot0" ];
      checkReversePath = false; # https://github.com/NixOS/nixpkgs/issues/10101

      extraCommands = ''
        iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eth0 -j MASQUERADE
        iptables -t nat -A POSTROUTING -s 10.0.10.0/24 -o eth0 -j MASQUERADE
        #BLOCK IOT FROM INTERNET but allow my laptop to access internet
        iptables -A FORWARD -i iot0 -m mac --mac-source B4:69:21:62:5A:C5  -j ACCEPT
        iptables -A FORWARD -i iot0 -o eth0 -j REJECT
      '';

      allowedTCPPortRanges = [ ];
      allowedUDPPortRanges = [ ];

      allowedTCPPorts = [ 22 8096 8123 5000 7878 ];
      allowedUDPPorts = [ 53 ];
    };
  };
}
