{ config, lib,inputs, pkgs, ... }: {
  services.home-assistant = {
    enable = true;
    package = (pkgs.unstable.home-assistant.override {
      extraPackages = py: with py; [ psycopg2 aiohttp-cors netdisco zeroconf pymetno pyipp brother ];
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
      webrtc = { };
      frigate = { };
      mqtt = { };
      recorder.db_url = "postgresql://@/hass";
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      zha = {
        database_path = "/state/hass/zigbee.db";
      };
    };

  };

  systemd.tmpfiles.rules = [
    # integrations
    "d /var/lib/hass/custom_components 0755 hass hass"
    "L /var/lib/hass/custom_components/frigate - - - - ${inputs.frigate-hass-integration}/custom_components/frigate"
    "L /var/lib/hass/custom_components/webrtc - - - - ${inputs.webrtc-card}/custom_components/webrtc"

    # #front end
    # "C /var/lib/hass/www/community/frigate-hass-card/frigate-hass-card.js - - - - ${sources.frigate-hass-card}/frigate-hass-card.js"
    # "C /var/lib/hass/www/community/simple-thermostat/simple-thermostat.js - - - - ${sources.simple-thermostat-card}/simple-thermostat.js"
    # "Z /var/lib/hass/www/ 770 hass hass - -"
    # "Z /var/lib/hass/www/community 770 hass hass - -"
  ];
}
