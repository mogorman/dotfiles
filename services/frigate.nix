{ config, lib, pkgs, ... }: {
  imports = [ ../secrets/frigate.nix ];
  virtualisation.oci-containers.containers.frigate = {
    image = "blakeblackshear/frigate:stable-amd64";
    ports = [ "127.0.0.1:5000:5000" "10.0.42.1:1935:1935" ];
    volumes = [
      "/external/16tb/state/frigate/media:/media/frigate"
      "${./frigate.yml}:/config/config.yml:ro"
      "/etc/localtime:/etc/localtime:ro"
    ];
    extraOptions = [
      "--shm-size=256m"
      "--add-host=host.docker.internal:host-gateway"
      "--dns=10.0.2.1"
      "--device=/dev/apex_0:/dev/apex_0"
      "--device=/dev/apex_1:/dev/apex_1"
      "--device=/dev/dri/renderD128"
      "--mount=type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000"
      "--pull=always"
    ];
  };
  systemd.services.docker-frigate = {
    after = [ "mosquitto.service" ];
    requires = [ "mosquitto.service" ];
    wants = [ "home-assistant.service" ];
  };
}
