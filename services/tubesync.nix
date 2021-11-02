{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.tubesync = {
    image = "ghcr.io/meeb/tubesync:latest";
    ports = [ "4848:4848" ];
    volumes = [
      "/external/06tb/staging_youtube/config:/config"
      "/external/06tb/staging_youtube/downloads:/downloads"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
       PUID="1002";
       PGID="100";

    };
    extraOptions = [
      "--pull=always"
    ];
  };
}
