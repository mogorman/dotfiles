{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "21.11";
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  time.timeZone = "US/Eastern";
  boot.kernel.sysctl = { "vm.swappiness" = 1; };
  boot.tmpOnTmpfs = true;
  boot.cleanTmpDir = true;

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      inconsolata # monospaced
      ubuntu_font_family # Ubuntu fonts
      unifont # some international languages
      corefonts
      mononoki
      victor-mono
      terminus_font
      terminus_font_ttf
    ];
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
