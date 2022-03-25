{ config, lib, inputs, pkgs, ... }: {
  services.zigbee2mqtt = {
    enable = true;
    package = pkgs.unstable.zigbee2mqtt;
    settings = {
      availability = {
        active = { timeout = 10; };
        passive = { timeout = 1500; };
      };
      frontend = {
        port = 8124;
        host = "127.0.0.1";
        uri = "https://zigbee.rldn.net";
      };
      mqtt = {
        user = "zigbee";
        password = config.services.home-assistant.config.mqtt.password;
      };
      homeassistant = config.services.home-assistant.enable;
      advanced = {
        elapsed = true;
        last_seen = "ISO_8601_local";
        channel = 25;
      };
      permit_join = true;
      experimental = {
        new_api = true;
        transmit_power = 10;
      };
      serial = { port = "tcp://zigbee:6638"; };
    };
  };
}
