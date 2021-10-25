{ config, lib, pkgs, ... }: {
  imports = [ ../secrets/mosquitto_acl.nix ];

  services.mosquitto.enable = true;
  services.mosquitto.checkPasswords = true;
  systemd.services.mosquitto = { wants = [ "docker-frigate.service" ]; };
}
