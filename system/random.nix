{ config, lib, pkgs, inputs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./common.nix
    ../services/ssh.nix
    ../services/frigate.nix
    ../services/mosquitto.nix
    ../services/mumble.nix
    ../services/postgresql.nix
    ../services/homeassistant.nix
    ../services/media.nix
    ../packages/packages.nix
    ../users/mog.nix
    ../users/media.nix
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="apex", MODE="0660", GROUP="users"
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

  networking.firewall.enable = false;
  networking.hostName = "random";

  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.enp3s0.useDHCP = false;
}

