{ config, lib, pkgs, ... }: {
  services.home-assistant = {
    enable = true;
    package = (pkgs.unstable.home-assistant.override {
      extraPackages = py: with py; [ psycopg2 aiohttp-cors netdisco zeroconf ];
    });

    config = {
      homeassistant = {
        name = "Home";
      };
      frontend = { themes = "!include_dir_merge_named themes"; };
      http = { };

      recorder.db_url = "postgresql://@/hass";
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
    };

  };
}
