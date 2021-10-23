{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "random";

  time.timeZone = "US/Eastern";
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.enp3s0.useDHCP = false;
  environment.systemPackages = with pkgs; [ vim wget git nixfmt ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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

}

