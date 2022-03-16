{ config, lib, pkgs, inputs, ... }: {
  imports = [
    "${inputs.nixos-hardware}/microsoft/surface/firmware/surface-go/ath10k"
    ./common.nix
    ../secrets/secrets.nix
    ../secrets/pepsi.nix
    ../packages/packages.nix
    ../packages/gui_packages.nix
    ../users/mog.nix
#    ../services/debian.nix
     ../services/builder.nix
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7e45da46-102f-4c5e-9064-14bbfc5f8a58";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6B22-618E";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/swapfile"; }];

  environment.etc.machine-info.text = ''
    CHASSIS=laptop
    ICON_NAME=computer
  '';

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_5_16;

  boot.kernelPatches = [
    {
      name = "battery patch";
      patch = ../patches/battery.patch;
    }
    {
      name = "camera patch";
      patch = ../patches/camera.patch;
    }
  ];

  networking.hostName = "madrox"; # Define your hostname.

#  networking.wireguard.interfaces = {
#    # "wg0" is the network interface name. You can name the interface arbitrarily.
#    wg0 = {
#      # Determines the IP address and subnet of the client's end of the tunnel interface.
#      ips = [ "10.0.42.2/24" ];
#      listenPort = 51820; # to match firewall allowedUDPPorts (without this wg uses random port numbers)
#
#      # Path to the private key file.
#      #
#      # Note: The private key can also be included inline via the privateKey option,
#      # but this makes the private key world-readable; thus, using privateKeyFile is
#      # recommended.
#      privateKeyFile = "${../secrets/madrox_private}";
#
#      peers = [
#        # For a client configuration, one peer entry for the server will suffice.
#
#        {
#          # Public key of the server (not a file path).
#          publicKey = "FEa4tK4tWa3xWCtzrLMBFTcpMVzu/S4xKm7VKxb4TDQ=";
#
#          # Forward all the traffic via VPN.
#          #allowedIPs = [ "0.0.0.0/0" ];
#          # Or forward only particular subnets
#          allowedIPs = [ "10.0.42.0/24" ];
#
#          # Set this to the server IP and port.
#          endpoint = "73.114.145.39:51820"; # ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577
#
#          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
#          persistentKeepalive = 25;
#        }
#      ];
#    };
#  };

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "ecryptfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.intel.updateMicrocode = true;
  virtualisation.hypervGuest.enable = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  hardware.sensor.iio.enable = true;
  boot.extraModprobeConfig = ''
    options i915 enable_fbc=1 enable_rc6=1 modeset=1
    options snd_hda_intel power_save=1
    options snd_ac97_codec power_save=1
    options iwlwifi power_save=Y
  '';

  # options iwldvm force_cam=N
  boot.kernelParams = [
    "intel_pstate=no_hwp"
    "mem_sleep_default=deep"
    "acpi_enforce_resources=lax"
  ];
  security.pam.enableEcryptfs = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = false;

  services.thermald.enable = true;
  services.thermald.configFile = ../packages/thermald.xml;
  boot.plymouth.enable = true;
  programs.gnupg.agent.pinentryFlavor = "gnome3";
  # Brydge keyboard Input device ID: bus 0x5 vendor 0x3f6 product 0xa001 version 0x1
  # power button Input device ID: bus 0x19 vendor 0x0 product 0x0 version 0x0

  services.udev.extraHwdb = ''
    evdev:input:b0019v0000p0000*
      KEYBOARD_KEY_ce=screenlock

    evdev:input:b0005v03F6pA001*
      KEYBOARD_KEY_10082=screenlock
      KEYBOARD_KEY_70039=leftctrl
  '';
}
