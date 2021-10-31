{ config, lib, pkgs, ... }: {
  imports = [ ../secrets/mosquitto_acl.nix ];

  services.mosquitto = {
    enable = true;
    checkPasswords = true;
    host = "0.0.0.0";
};
  systemd.services.mosquitto = { wants = [ "docker-frigate.service" ]; };
}
