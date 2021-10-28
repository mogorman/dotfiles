{ config, lib, inputs, pkgs, ... }: {
    imports = [ ../secrets/homeassistant.nix ];
  services.home-assistant = {
    enable = true;
    configWritable = true;
    lovelaceConfigWritable = true;
    package = (pkgs.unstable.home-assistant.override {
      extraPackages = py:
        with py; [
          psycopg2
          aiohttp-cors
          netdisco
          zeroconf
          pymetno
          pyipp
          brother
        ];
    });
    lovelaceConfig = {
      resources = [
        {
          url = "/local/frigate-hass-card.js";
          type = "module";
        }
        {
          url = "/local/simple-thermostat.js";
          type = "module";
        }
      ];

      title = "Home";
      views = [{
        title = "Example";
        cards = [
          {
            type = "markdown";
            title = "Lovelace";
            content = "Welcome to no more pi";
          }
          {
            type = "entities";
            title = "Person";
            entities = [ "person.mog" ];
          }
          {
            type = "entities";
            title = "Sensor";
            entities = [
              "sensor.back_camera_fps"
              "sensor.back_detection_fps"
              "sensor.back_dog"
              "sensor.back_mouse"
              "sensor.back_person"
              "sensor.back_process_fps"
              "sensor.back_skipped_fps"
              "sensor.coral_inference_speed"
              "sensor.detection_fps"
            ];
          }
          {
            type = "custom:frigate-card";
            dimensions = { };
            controls = { nextprev = "chevrons"; };
            live_provider = "webrtc";
            camera_entity = "camera.back";
            webrtc = { url = "rtsp://doorcam:8554/unicast"; };
            view_default = "snapshot";
            menu_buttons = {
              frigate_ui = true;
              fullscreen = true;
              frigate = false;
            };
            menu_mode = "hover-top";
          }

        ];
      }];
    };

    config = {
      homeassistant = { name = "Home"; };
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
      mqtt = {
        broker = "localhost";
        username = "home";
        discovery = true;
        discovery_prefix = "homeassistant";

      };
      recorder.db_url = "postgresql://@/hass";
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      zha = { database_path = "/state/hass/zigbee.db"; };
    };
  };

  systemd.tmpfiles.rules = [
    # integrations
    "d /var/lib/hass/custom_components 0755 hass hass"
    "L /var/lib/hass/custom_components/frigate - - - - ${inputs.frigate-hass-integration}/custom_components/frigate"
    "L /var/lib/hass/custom_components/webrtc - - - - ${inputs.webrtc-card}/custom_components/webrtc"

    # #front end
    "d /var/lib/hass/www 0755 hass hass"
    "C /var/lib/hass/www/frigate-hass-card.js 0755 hass hass - ${
      ../hass/frontend/frigate-hass-card.js
    }"
    "C /var/lib/hass/www/simple-thermostat.js 0755 hass hass - ${
      ../hass/frontend/simple-thermostat.js
    }"
  ];
}
