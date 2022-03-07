{ config, lib, pkgs, inputs, ... }: {
  imports = [
    "${inputs.nixos-hardware}/microsoft/surface/firmware/surface-go/ath10k"
    ./common.nix
    ../secrets/secrets.nix
    ../secrets/pepsi.nix
    ../packages/packages.nix
    ../packages/gui_packages.nix
    ../users/mog.nix
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
}
