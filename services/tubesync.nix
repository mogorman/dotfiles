{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.tubesync = {
    image = "ghcr.io/meeb/tubesync:latest";
    ports = [ "127.0.0.1:4848:4848" ];
    volumes = [
      "/mnt/drive_1/staging_youtube/config:/config"
      "/mnt/drive_1/state/jellyfin/youtube:/downloads"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
       PUID="1002";
       PGID="100";
       TUBESYNC_WORKERS="8";
       #DATABASE_CONNECTION="postgresql://tubesync:@host.docker.internal:5432/tubesync";
       #DATABASE_CONNECTION="postgresql://tubesync:ashpinipasd@host.docker.internal:5432/tubesync";
    };
    extraOptions = [
      "--pull=always"
     # "--cidfile=%t/%n.ctr-id"
     # "--add-host=host.docker.internal:host-gateway"
    ];
  };
}
