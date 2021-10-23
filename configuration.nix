# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "random"; # Define your hostname.

  time.timeZone = "US/Eastern";
  networking.useDHCP = false;
  networking.interfaces.enp2s0.useDHCP = true;
  networking.interfaces.enp3s0.useDHCP = false;
   environment.systemPackages = with pkgs; [
     vim
     wget
     git
];

   programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };

  services.openssh.enable = true;

  system.stateVersion = "21.05"; # Did you read the comment?
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  boot.initrd.luks.devices.luksroot = { device = "/dev/disk/by-uuid/6143d5ea-2cf1-41b8-ab52-da5d6c4b4e86"; preLVM = true; allowDiscards = true; };

   users.users.mog = {
     initialHashedPassword="test";
     isNormalUser = true;
     extraGroups = [ "wheel" "docker"]; # Enable ‘sudo’ for the user.
   };

}


