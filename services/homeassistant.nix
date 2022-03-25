{ config, lib, inputs, pkgs, ... }: {
  imports = [
    ../secrets/homeassistant.nix
    "${inputs.unstable}/nixos/modules/services/home-automation/home-assistant.nix"
  ];

  disabledModules = [ "services/misc/home-assistant.nix" ];

  systemd.services.home-assistant = {
    after = [ "docker-frigate.service" ];
    requires = [ "docker-frigate.service" ];
  };
  services.home-assistant = {
    enable = true;
    configWritable = true;
    lovelaceConfigWritable = true;
    package = (pkgs.unstable.home-assistant.override {
      extraPackages = python3Packages:
        with python3Packages; [
          psycopg2
          aiohttp
          aiohttp-cors
          websockets
          netdisco
          zeroconf
          pymetno
          pyipp
          brother
          yarl
          pyruckus
          getmac
          python-nmap
          pkgs.openssh
          pkgs.unstable.nmap
          (callPackage ../packages/mac_vendor_lookup.nix { })
          #          (callPackage ../packages/ocpp.nix { })
        ];
    }).overrideAttrs (oldAttrs: { doInstallCheck = false; });

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
        {
          url = "/local/upcoming-media-card.js";
          type = "module";
        }
        # {
        #   url = "/local/zha-network-card.js";
        #   type = "js";
        # }
        {
          url = "/local/entity-attributes-card.js?=v2";
          type = "js";
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
            type = "weather-forecast";
            entity = "weather.home";
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

              "sensor.outdoor1_camera_fps"
              "sensor.outdoor1_detection_fps"
              "sensor.outdoor1_dog"
              "sensor.outdoor1_mouse"
              "sensor.outdoor1_person"
              "sensor.outdoor1_process_fps"
              "sensor.outdoor1_skipped_fps"

              "sensor.coral_inference_speed"
              "sensor.detection_fps"

              "sensor.wallbox_portal_charging_speed"
              "sensor.wallbox_portal_status_description"
              "sensor.wallbox_portal_cost"
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
          {
            type = "custom:frigate-card";
            dimensions = { };
            controls = { nextprev = "chevrons"; };
            live_provider = "webrtc";
            camera_entity = "camera.outdoor1";
            webrtc = {
              url = "rtsp://admin:${config.camera_password}@outdoor1:554/";
            };
            view_default = "snapshot";
            menu_buttons = {
              frigate_ui = true;
              fullscreen = true;
              frigate = false;
            };
            menu_mode = "hover-top";
          }

          {
            type = "custom:upcoming-media-card";
            entity = "sensor.sonarr_upcoming_media";
            image_style = "fanart";
            max = 10;
            hide_empty = true;
          }
        ];
      }];
    };

    config = {
      homeassistant = { name = "Home"; };
      frontend = { themes = "!include_dir_merge_named themes"; };
      http = {
        trusted_proxies = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
      };
      default_config = { };
      config = { };
      frontend = { };
      mobile_app = { };
      discovery = { };
      zeroconf = { };
      webrtc = { };
      frigate = { };
      dahua = { };
      #      ocpp = { };
      wallbox = { };
      ruckus = { };
      nmap = { };

      # {"id": "1640747399287", "alias": "New Automation", "description": "", "trigger": [{"platform": "device", "type": "turned_off", "device_id": "58c923e15372dfada5e4622bb53747ee", "entity_id": "switch.wallbox_availability", "domain": "switch"}], "condition": [], "action": [{"type": "turn_on", "device_id": "58c923e15372dfada5e4622bb53747ee", "entity_id": "switch.wallbox_charge_control", "domain": "switch"}], "mode": "single"}
      "automation sunset" = {
        id = "1627073230480";
        alias = "Sunset";
        trigger = [{
          platform = "sun";
          event = "sunset";
          offset = "+00:15:00";
        }];
        action = [
          {
            entity_id = "light.lamppost_1";
            domain = "light";
            type = "turn_on";
            device_id = "c2392a738e3623d24a49752e17467c75";
          }
          {
            entity_id = "light.lamppost_2";
            domain = "light";
            type = "turn_on";
            device_id = "bba055d1b122c1a1329d25118dc06ea";
          }
          {
            entity_id = "light.side_door_light";
            domain = "light";
            device_id = "24cc707bed0d05ad130d99358ba8e3e4";
            type = "turn_on";
          }
          {
            entity_id = "light.front_porch_1";
            domain = "light";
            device_id = "429e6e7aab59263b1bf81b04439bfd6c";
            type = "turn_on";
          }
          {
            entity_id = "light.front_porch_2";
            domain = "light";
            device_id = "120d7bb944f4e5583d193615266934cf";
            type = "turn_on";
          }
          {
            entity_id = "light.front_porch_3";
            domain = "light";
            device_id = "ab59f649413d62e1d19bb81a6177882b";
            type = "turn_on";
          }
          {
            entity_id = "cover.blinds";
            domain = "cover";
            device_id = "a9ba231cb93146b61dae85362d4ee13a";
            type = "set_position";
            position = 15;
          }
        ];
      };
      "automation sunrise" = {
        id = "1627073230481";
        alias = "Sunrise";
        trigger = [{
          platform = "sun";
          event = "sunrise";
          offset = "+00:15:00";
        }];
        action = [
          {
            entity_id = "light.lamppost_1";
            domain = "light";
            type = "turn_off";
            device_id = "c2392a738e3623d24a49752e17467c75";
          }
          {
            entity_id = "light.lamppost_2";
            domain = "light";
            type = "turn_off";
            device_id = "bba055d1b122c1a1329d25118dc06ea";
          }
          {
            entity_id = "light.side_door_light";
            domain = "light";
            type = "turn_off";
            device_id = "24cc707bed0d05ad130d99358ba8e3e4";
          }
          {
            entity_id = "light.front_porch_1";
            domain = "light";
            device_id = "429e6e7aab59263b1bf81b04439bfd6c";
            type = "turn_off";
          }
          {
            entity_id = "light.front_porch_2";
            domain = "light";
            device_id = "120d7bb944f4e5583d193615266934cf";
            type = "turn_off";
          }
          {
            entity_id = "light.front_porch_3";
            domain = "light";
            device_id = "ab59f649413d62e1d19bb81a6177882b";
            type = "turn_off";
          }
          {
            entity_id = "cover.blinds";
            domain = "cover";
            device_id = "a9ba231cb93146b61dae85362d4ee13a";
            type = "set_position";
            position = 96;
          }
        ];
      };

      script = {
        open_livingroom_blinds = {
          alias = "open livingroom blinds";
          mode = "single";
          sequence = [{
            entity_id = "cover.blinds";
            domain = "cover";
            device_id = "a9ba231cb93146b61dae85362d4ee13a";
            type = "set_position";
            position = 96;
          }];
        };
        close_livingroom_blinds = {
          alias = "close livingroom blinds";
          mode = "single";
          sequence = [{
            entity_id = "cover.blinds";
            domain = "cover";
            device_id = "a9ba231cb93146b61dae85362d4ee13a";
            type = "set_position";
            position = 15;
          }];
        };
      };
      #      "automation charger" = {
      #        id = "1627073230476";
      #        alias = "Charge Car";
      #        description = "Flip switch to allow ocpp to charge car";
      #        mode = "single";
      #        trigger = [{
      #          platform = "device";
      #          type = "turned_off";
      #          entity_id = "switch.wallbox_availability";
      #          domain = "switch";
      #          device_id = "58c923e15372dfada5e4622bb53747ee";
      #        }];
      #        action = [{
      #          type = "turn_on";
      #          entity_id = "switch.wallbox_charge_control";
      #          domain = "switch";
      #          device_id = "58c923e15372dfada5e4622bb53747ee";
      #        }];
      #      };
      sensor = [
        {
          platform = "sonarr_upcoming_media";
          api_key = "5ee9c6e6d58a428db80cd15540f58fec";
          host = "127.0.0.1";
          port = 8989;
          days = 7;
          ssl = false;
          max = 10;
        }
        {
          platform = "template";
          sensors = {
            outdoor_temperature = {
              friendly_name = "outside";
              unit_of_measurement = "°F";
              value_template =
                "{{ state_attr('weather.home', 'temperature') }}";
            };
          };
        }
      ];
      notify = { };
      met = {
        name = "Home";
        latitude = 42.22589962769912;
        longitude = -70.94125270843507;
      };
      mqtt = {
        broker = "localhost";
        username = "home";
        discovery = true;
        discovery_prefix = "homeassistant";

      };
      recorder.db_url = "postgresql://@/hass";
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
      #      zha = { };
      owntracks = { };
      media_player = [{
        platform = "emby";
        host = "127.0.0.1";
        api_key = "23011c9c5ae84f66a8ea6d65e9fb238f";
      }];
      esphome = { };
      habitica = [{
        api_user = "c254025e-c368-45f8-937a-279260a0be37";
        api_key = "7bcd4487-148b-47fb-9a51-83cf324048d9";
        name = "mog";
        url = "https://habitica.com";
      }];
      timer = { test = { duration = "01:00:00"; }; };
      shopping_list = { };
    };
  };

  systemd.tmpfiles.rules = [
    # integrations
    "R /var/lib/hass/custom_components"
    "d /var/lib/hass/custom_components 0755 hass hass"
    "L /var/lib/hass/custom_components/frigate - - - - ${inputs.frigate-hass-integration}/custom_components/frigate"
    "L /var/lib/hass/custom_components/dahua - - - - ${inputs.dahua-hass}/custom_components/dahua"

    #    "L /var/lib/hass/custom_components/ocpp - - - - ${inputs.ocpp-hass-integration}/custom_components/ocpp"
    "L /var/lib/hass/custom_components/webrtc - - - - ${inputs.webrtc-card}/custom_components/webrtc"
    "L /var/lib/hass/custom_components/sonarr_upcoming_media - - - - ${inputs.sonarr_ha}/custom_components/sonarr_upcoming_media"

    # #front end
    "R /var/lib/hass/www"
    "d /var/lib/hass/www 0755 hass hass"
    "C /var/lib/hass/www/frigate-hass-card.js 0755 hass hass - ${
      ../hass/frontend/frigate-hass-card.js
    }"
    "C /var/lib/hass/www/simple-thermostat.js 0755 hass hass - ${
      ../hass/frontend/simple-thermostat.js
    }"
    "C /var/lib/hass/www/upcoming-media-card.js 0755 hass hass - ${inputs.upcoming-media-card}/upcoming-media-card.js"
    #    "C /var/lib/hass/www/zha-network-card.js 0755 hass hass - ${inputs.zha-network-card}/zha-network-card.js"
    "C /var/lib/hass/www/entity-attributes-card.js 0755 hass hass - ${inputs.entity-attributes-card}/entity-attributes-card.js"
  ];

  systemd.services.esphome = {
    description = "esphome";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.unstable.esphome pkgs.esptool pkgs.git ];
    serviceConfig = {
      User = "mog";
      ExecStart = "${
          (pkgs.callPackage ../packages/mog_esphome.nix { })
        }/bin/esphome dashboard /home/mog/code/dotfiles/esphome";
    };
  };

}
