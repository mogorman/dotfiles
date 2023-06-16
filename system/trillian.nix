{ config, lib, pkgs, inputs, ... }: {
  imports = [
    ./common.nix
    ../secrets/secrets.nix
    ../services/ssh.nix
    ../packages/desktop_packages.nix
    ../users/mog.nix
  ];
  services.udev.extraRules = ''
    SUBSYSTEM=="apex", MODE="0660", GROUP="users"
    ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="b8:85:84:b8:ae:2c", NAME="eth0"
  '';
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.reusePassphrases = true;
  hardware.enableRedistributableFirmware = true;

  boot.loader.grub.enable = true;

  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  # Grub menu is painted really slowly on HiDPI, so we lower the
  # resolution. Unfortunately, scaling to 1280x720 (keeping aspect
  # ratio) doesn't seem to work, so we just pick another low one.
  boot.loader.grub.gfxmodeEfi = "1920x1080";
  # HARDWARE CONFIG
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];

  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot = {
    kernelParams =
      [ "acpi_rev_override" "mem_sleep_default=deep" "intel_iommu=igfx_off" ];
    # "nvidia-drm.modeset=1" ];
    #    extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  };

  #  hardware.nvidia.prime = {
  #     offload.enable = false;
  # #    sync.enable = true;
  #     nvidiaBusId = "PCI:1:0:0";
  #     intelBusId = "PCI:0:2:0";
  #   };

  boot.initrd.luks.devices.luksroot = {
    device = "/dev/disk/by-uuid/9670fdb2-20b0-44e2-9ef0-812ea1dc848f";
    preLVM = true;
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fc0380c1-a76b-496f-a0c5-983c387e189b";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1A8C-D29A";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/6a72f228-9502-43bb-86bb-65e6ade7b820"; }];

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
    # have to do this otherwise tor does not want to start
    chmod -R 700 /etc/tor

    echo "make sure localhost is up"
    ip a a 127.0.0.1/8 dev lo
    ip link set lo up

    echo "tor: starting tor"
    tor -f ${torRc} --verify-config
    tor -f ${torRc} &
  '';

  networking.hostName = "trillian"; # Define your hostname.
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  services.flatpak.enable = true;

  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  #  services.xserver.displayManager.gdm.nvidiaWayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;

  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  networking.firewall.enable = false;
  #  hardware.nvidia.powerManagement.enable  = false;
  # hardware.nvidia.modesetting.enable = true;
  # services.xserver.videoDrivers = [ "nvidia" ]; #modesetting before probably wrong probably modeset
  hardware.opengl.driSupport32Bit = true;
  programs.steam.enable = true;

  virtualisation.docker.enable = true;
  # virtualisation.docker.enableNvidia = true;
  services.lorri.enable = true;
  systemd.enableUnifiedCgroupHierarchy = false;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.blacklistedKernelModules = [
  #  "i2c_nvidia_gpu"
  # ];

  programs.adb.enable = true;
  #hardware.nvidia.nvidiaPersistenced = true;

  systemd.user.services = {
    pepsi_postgres = {
      enable = true;
      wantedBy = [ "default.target" ];
      description = "pepsi postgres";
      serviceConfig = {
        WorkingDirectory = "/home/mog/code/pepsico";

        ExecStart =
          "${pkgs.postgresql}/bin/postgres -D /home/mog/code/pepsico/.postgres/ -k /home/mog/code/pepsico/.postgres/run";
        Restart = "always";
      };
    };

    strongdm = {
      enable = true;
      wantedBy = [ "default.target" ];
      description = "strongdm vpn";
      serviceConfig = {
        WorkingDirectory = "/home/mog";

        ExecStart =
          "${(pkgs.callPackage ../packages/sdm.nix { })}/bin/sdm listen";
        Restart = "always";
      };
    };
  };

  hardware = { nitrokey.enable = true; };
  security.pam.enableSSHAgentAuth = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };
  };

  services.tor.enable = true;
  services.tor.client.enable = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  hardware.nvidia.modesetting.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprland.nvidiaPatches = true;
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs;
    [
      (river.overrideAttrs (prevAttrs: rec {
        postInstall = let
          riverSession = ''
            [Desktop Entry]
            Name=River
            Comment=Dynamic Wayland compositor
            Exec=river
            Type=Application
          '';
        in ''
          mkdir -p $out/share/wayland-sessions
          echo "${riverSession}" > $out/share/wayland-sessions/river.desktop
        '';
        passthru.providedSessions = [ "river" ];
      }))

    ];

  services.xserver.displayManager.sessionPackages = [
    (pkgs.river.overrideAttrs (prevAttrs: rec {
      postInstall = let
        riverSession = ''
          [Desktop Entry]
          Name=River
          Comment=Dynamic Wayland compositor
          Exec=river
          Type=Application
        '';
      in ''
        mkdir -p $out/share/wayland-sessions
        echo "${riverSession}" > $out/share/wayland-sessions/river.desktop
      '';
      passthru.providedSessions = [ "river" ];
    }))
  ];
}
