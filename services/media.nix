{ config, lib, pkgs, ... }: {

#  services.jellyfin = {
#    user = "media";
#    group = "users";
#    enable = true;
#  };
#  systemd.services.jellyfin = {
#   serviceConfig = {      DeviceAllow= pkgs.lib.mkForce "char-drm rwm";
#};
#};
#

 systemd.services.jellyfin = {
      description = "Jellyfin Media Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "media";
        Group = "users";
        StateDirectory = "jellyfin";
        CacheDirectory = "jellyfin";
        ExecStart = "${pkgs.unstable.jellyfin}/bin/jellyfin --datadir '/var/lib/jellyfin' --cachedir '/var/cache/jellyfin'";
      };
    };

 systemd.services.jellyseerr = {
      description = "Jellyfin Media Getter";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.nodejs pkgs.yarn ];

      serviceConfig = {
        User = "media";
        Group = "users";
        WorkingDirectory = "/mnt/drive_1/state/jellyseerr";
        StateDirectory =   "/mnt/drive_1/state/jellyseerr";
        CacheDirectory =   "/mnt/drive_1/state/jellyseerr";
        ExecStart = "${pkgs.yarn}/bin/yarn start";
      };
    };

 services.jackett = {
   enable = true;
   user = "media";
   group = "users";
   dataDir = "/mnt/drive_1/state/jackett";
 };

  services.sonarr = {
    enable = true;
    user = "media";
    group = "users";
    dataDir = "/mnt/drive_1/state/sonarr";
  };



  systemd.services.radarr.environment.LD_LIBRARY_PATH="${lib.getLib pkgs.zlib}/lib";
  services.radarr = {
    enable = true;
    user = "media";
    group = "users";
    dataDir = "/mnt/drive_1/state/radarr";
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

###  systemd.services.unstable_bazarr = {
###    description = "Keep our subitles up to date";
###    after = [ "network.target" ];
###    wantedBy = [ "multi-user.target" ];
###    path = [ pkgs.unstable.bazarr ];
###    serviceConfig = {
###      User = "media";
###      Type = "simple";
###        ExecStart = pkgs.writeShellScript "start-bazarr" ''
###          ${pkgs.unstable.bazarr}/bin/bazarr \
###            --config '/var/lib/bazarr' \
###            --port 6767 \
###            --no-update True
###        '';
###      Restart = "on-failure";
###    };
###  };
###
###
}
