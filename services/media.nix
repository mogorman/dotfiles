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

  systemd.services.xmltv_getter = {
    description = "Keep our tv media in sync";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.bash pkgs.python39 pkgs.python39Packages.configparser ];
    startAt="*-*-* 00:00:00";
    #startAt="*:0/15";
    serviceConfig = {
      User = "media";
      ExecStart = "/home/media/update_xml.sh";
      Restart = "no";
    };
  };

}
