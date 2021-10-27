{ config, lib, pkgs, ... }: {

  services.jellyfin = {
    user = "media";
    group = "users";
    enable = true;
  };

  services.jackett = {
    enable = true;
    user = "media";
    group = "users";
    dataDir = "/state/jackett";
  };

  services.sonarr = {
    enable = true;
    user = "media";
    group = "users";
    dataDir = "/state/sonarr";
  };

  services.radarr = {
    enable = true;
    user = "media";
    group = "users";
    dataDir = "/state/radarr";
  };

  services.bazarr = {
    enable = true;
    user = "media";
    group = "users";
  };

}
