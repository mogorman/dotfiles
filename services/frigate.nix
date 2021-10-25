{ config, lib, pkgs, ... }: {
  environment.etc."nixos/frigate_config.yml".source = ./frigate.yml;
  virtualisation.oci-containers.containers.frigate = {
    image = "blakeblackshear/frigate:stable-amd64";
    ports = [ "5000:5000" "1935:1935" ];
    environment = { FRIGATE_RTSP_PASSWORD = "password"; };
    volumes = [
      "/state/frigate/media:/media/frigate"
      "/etc/nixos/frigate_config.yml:/config/config.yml:ro"
      "/etc/localtime:/etc/localtime:ro"
    ];
    extraOptions = [
      "--shm-size=64m"
      "--device=/dev/apex_0:/dev/apex_0"
      "--device=/dev/dri/renderD128"
      "--mount=type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000"
    ];
  };
}
