{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.tubesync = {
    image = "ghcr.io/meeb/tubesync:latest";
    ports = [ "127.0.0.1:4848:4848" ];
    volumes = [
      "/external/06tb/staging_youtube/config:/config"
      "/external/06tb/staging_youtube/downloads:/downloads"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
       PUID="1002";
       PGID="100";
       DATABASE_CONNECTION="postgresql://tubesync:@host.docker.internal:5432/tubesync";
       #DATABASE_CONNECTION="postgresql://tubesync:ashpinipasd@host.docker.internal:5432/tubesync";
    };
    extraOptions = [
      "--pull=always"
      "--add-host=host.docker.internal:host-gateway"
    ];
  };
}
