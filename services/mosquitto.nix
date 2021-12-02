{ config, lib, pkgs, ... }: {
  imports = [ ../secrets/mosquitto_acl.nix ];

  services.mosquitto = {
    enable = true;
};
  systemd.services.mosquitto = { wants = [ "docker-frigate.service" ]; };
}
