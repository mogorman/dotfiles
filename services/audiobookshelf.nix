{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.audiobookshelf = {
    image = "advplyr/audiobookshelf:latest";
    ports = [ "4849:80" ];
    volumes = [
      "/mnt/drive_1/state/audiobooks/audiobooks:/audiobooks"
      "/mnt/drive_1/state/audiobooks/audible:/audible"
      "/mnt/drive_1/state/audiobooks/podcasts:/podcasts"
      "/mnt/drive_1/state/audiobooks/config:/config"
      "/mnt/drive_1/state/audiobooks/metadata:/metadata"
      "/etc/localtime:/etc/localtime:ro"
    ];
    environment = {
       PUID="1002";
       PGID="100";
       REBUILD="true";
    };
    extraOptions = [
      "--pull=always"
    ];
  };
}
