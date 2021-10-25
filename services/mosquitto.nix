{ config, lib, pkgs, ... }: {
  imports = [ ../secrets/mosquitto_acl.nix ];

  services.mosquitto.enable = true;
  services.mosquitto.allowAnonymous = true;
  systemd.services.mosquitto = { wants = [ "docker-frigate.service" ]; };
}
