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
#
#  boot.kernelPatches = [
#    {
#      name = "battery patch";
#      patch = ../patches/battery.patch;
#    }
#    {
#      name = "camera patch";
#      patch = ../patches/camera.patch;
#    }
#  ];

#boot.kernelPackages = pkgs.linuxPackages_5_16;
boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_5_16.override {
    argsOverride = rec {
#src = pkgs.fetchgit {
#    url = "git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git";
#    rev = "v5.16.15";
#    sha256 = "sha256-fCq/Hq47ix7sdHeSKaouXX3BaFZgAH514yt7l8RYPKU";
# };
#       version = "5.16.15";
#       modDirVersion = "5.16.15";};
#      src = pkgs.fetchurl {
#            url = "https://codeload.github.com/linux-surface/kernel/zip/refs/heads/v5.16-surface-devel";
#            sha256 = "sha256-XUaeJWFk1i2r5dWptuU8QiyK95mBYz55d8nrazA+4ho=";
#      };
      src = pkgs.fetchFromGitHub {
            repo ="kernel";
            owner = "linux-surface";
            rev = "v5.16-surface-devel";
            sha256 ="sha256-041VL3Hn6gaHuDH9TbkaftGupGJnaOnYiCBBRjrCKuE=";
      };
      version = "5.16.0";
      modDirVersion = "5.16.0";
      };
  });
      boot.kernelPatches = [ {
        name = "cio2 bridge";
        patch = null;
        extraConfig = ''
                STAGING y
                STAGING_MEDIA y
                MEDIA_SUPPORT m
                PCI y
                VIDEO_V4L2 m
                X86 y
                #
                # Cameras: IPU3
                #
                VIDEO_IPU3_IMGU m
                VIDEO_IPU3_CIO2 m
                CIO2_BRIDGE y
                INTEL_SKL_INT3472 m
                REGULATOR_TPS68470 m
                COMMON_CLK_TPS68470 m
                GPIO_TPS68470 y
                #
                # Cameras: Sensor drivers
                #
                VIDEO_OV5693 m
                VIDEO_OV8865 m
              '';
        } ];

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
  #hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

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

  environment.systemPackages = with pkgs; [
#    libcamera
   (pkgs.libsForQt5.callPackage ../packages/qcam.nix { })
  ];


  programs.bash.shellInit = ''
export GST_PLUGIN_SYSTEM_PATH_1_0="${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0/:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0/:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0/:${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0/"
  '';
environment.extraInit = ''
export PATH="$HOME/.krew/bin:/home/mog/.bin:/home/mog/.emacs.d/bin:${pkgs.gst_all_1.gstreamer.dev}/bin:$PATH"
  '';
}
