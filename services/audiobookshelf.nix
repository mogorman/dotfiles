{ config, lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.audiobookshelf = {
    image = "advplyr/audiobookshelf:latest";
    ports = [ "4849:80" ];
    volumes = [
      "/external/06tb/state/audiobooks/audioboks:/audiobooks"
      "/external/06tb/state/audiobooks/config:/config"
      "/external/06tb/state/audiobooks/metadata:/metadata"
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
