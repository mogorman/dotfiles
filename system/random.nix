{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # HARDWARE CONFIG
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sdhci_pci"
    "rtsx_usb_sdmmc"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/41c0df27-00a5-40ee-9334-bb5737a0a124";
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

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "random";

  time.timeZone = "US/Eastern";
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.enp3s0.useDHCP = false;
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    nmap
    git
    nixfmt
    git-crypt
    gnupg
    pinentry
    pinentry-curses
    pciutils
  ];

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "curses";
  };

  services.openssh.enable = true;

  system.stateVersion = "21.05";
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  boot.initrd.luks.devices.luksroot = {
    device = "/dev/disk/by-uuid/6143d5ea-2cf1-41b8-ab52-da5d6c4b4e86";
    preLVM = true;
    allowDiscards = true;
  };

  users.users.mog = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    authorizedKeys =
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8ZL7Qr293/QIApN5iodPHf0rio/T6KsZYhomrBRZUIpu6THQrBLuop2VmJvqNnULuNz2WfJp220Arj7qLKrxlohkE+rssmYjHYxMuIdcToms+Pr9u1G9vmZ7DX1ms8d/1u7oyx8DQeE966nuVS229mrN8dy6DsfLOIj2ZHWb0Mf5EKiIBLFVR7fakKLkoX50sUVrns70yo5yM2EGQISM6K/pQ4FzbGndEy4x0HoF70406eF7TlKrEic4B8UOKFqe80cTZZTC+bBjeNUrG2EvSL4pFN64pqlRAZJeq2M3j1Ts1WKeewbtb1uJsbAZoM6d9TSffHr5cv/t5abq2KFZll2TzTpAr5zg9OOR80MCKhphoLBWlDOlMBuLtJO/BUVoFGoK1m9Nh+8g4RJAGS8WvQrVbkq6Rbo/rloXuEsXVrxwQwVH7gFj07NIO2322kJxBPaZ32RHnYrPIqAI3tH7Zz5TZrAxwhubVO3ZA65VbzDIFK0VP4hO4nRSaF1VYkm8wXv+LnefRp74FLzBjo1UN6CvBjzU5iWbQNsuGoXeyrarGIv53n6lY3VVtD51iEH2ZQB3Cr7YczJkwGFbe52QhmTAhNGZqd7uNyGJuXOo0NzNXWeXJ+/AbTZ5LtZ90f+/FyJcssyKcJHY6LjtTraN0FueRcFWv2GzKOEJj9cCoKw== cardno:000500006D02";
    hostKeys = [
      "/home/mog/code/dotfiles/secrets/keys/random_initrd__ssh_host_rsa_key"
      "/home/mog/code/dotfiles/secrets/keys/random_initrd__ssh_host_ed25519_key"
    ];
  };
  boot.initrd.availableKernelModules = [ "igb" ];
}

