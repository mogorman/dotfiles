{ config, lib, pkgs, ... }: {
  imports = [ ../secrets/frigate.nix ];
  virtualisation.oci-containers.containers.frigate = {
    image = "blakeblackshear/frigate:stable-amd64";
    ports = [ "5000:5000" "1935:1935" ];
    volumes = [
      "/external/04tb/state/frigate/media:/media/frigate"
      "${./frigate.yml}:/config/config.yml:ro"
      "/etc/localtime:/etc/localtime:ro"
    ];
    extraOptions = [
      "--shm-size=64m"
      "--add-host=host.docker.internal:host-gateway"
      "--device=/dev/apex_0:/dev/apex_0"
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
