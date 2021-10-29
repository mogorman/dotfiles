{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "21.05";
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  time.timeZone = "US/Eastern";
}
