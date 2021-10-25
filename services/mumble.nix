{ config, lib, pkgs, ... }: {
  imports = [ ../secrets/mumble.nix ];
  services.murmur = {
    enable = true;
    welcometext = "hi there!";
    registerName = "weymouth";
    bonjour = true;
  };
}
