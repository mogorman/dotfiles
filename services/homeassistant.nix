{ config, lib, pkgs, ... }: {
  services.home-assistant = {
    enable = true;
    package = (pkgs.unstable.home-assistant.override {
      extraPackages = py: with py; [ psycopg2 aiohttp-cors netdisco zeroconf pymetno pyipp ];
    });

    config = {
      homeassistant = {
        name = "Home";
      };
      frontend = { themes = "!include_dir_merge_named themes"; };
      http = { };
      default_config = { };
      config = { };
      frontend = { };
      mobile_app = { };
      discovery = { };
      zeroconf = { };
      recorder.db_url = "postgresql://@/hass";
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      zha = {
        database_path = "/state/hass/zigbee.db";
      };
    };

  };
}
