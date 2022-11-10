{ config, lib, pkgs, ... }: {
  systemd.services.sidedoor_mqtt = {
    description = "connect amcrest data to mqtt";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    enable = true;
    environment = {
      AMCREST_HOST = "sidedoor";
      #    AMCREST_PASSWORD= set in secrets/secrets.nix
      MQTT_USERNAME = "sidedoor";
      #    MQTT_PASSWORD = set in secrets/secrets.nix
      HOME_ASSISTANT = "true";
      STORAGE_POLL_INTERVAL = "0";
      DEVICE_NAME = "side doorbell";
      MODIFIED= "true";
    };
    unitConfig = {
      Type="simple";
    };
    serviceConfig = {
      User = "mog";
      Group = "users";
      StateDirectory = "amcrest2mqtt";
      Restart="always";
      CacheDirectory = "amcrest2mqtt";
      ExecStart = "/run/current-system/sw/bin/amcrest2mqtt";
      # ExecStart = "${(pkgs.callPackage ../packages/amcrest2mqtt.nix { })}/bin/amcrest2mqtt";
    };
  };
  systemd.services.frontdoor_mqtt = {
    description = "connect amcrest data to mqtt";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      AMCREST_HOST = "frontdoor";
      #    AMCREST_PASSWORD= set in secrets/secrets.nix
      MQTT_USERNAME = "frontdoor";
      #    MQTT_PASSWORD = set in secrets/secrets.nix
      HOME_ASSISTANT = "true";
      STORAGE_POLL_INTERVAL = "0";
      DEVICE_NAME = "front doorbell";
    };
    serviceConfig = {
      User = "mog";
      Group = "users";
      StateDirectory = "amcrest2mqtt";
      CacheDirectory = "amcrest2mqtt";
      ExecStart = "${
          (pkgs.callPackage ../packages/amcrest2mqtt.nix { })
        }/bin/amcrest2mqtt";
    };
  };
  systemd.services.babycam_mqtt = {
    description = "connect amcrest data to mqtt";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      AMCREST_HOST = "babycam";
      #    AMCREST_PASSWORD= set in secrets/secrets.nix
      MQTT_USERNAME = "babycam";
      #    MQTT_PASSWORD = set in secrets/secrets.nix
      HOME_ASSISTANT = "true";
      STORAGE_POLL_INTERVAL = "0";
      DEVICE_NAME = "front doorbell";
    };
    serviceConfig = {
      User = "mog";
      Group = "users";
      StateDirectory = "amcrest2mqtt";
      CacheDirectory = "amcrest2mqtt";
      ExecStart = "${
          (pkgs.callPackage ../packages/amcrest2mqtt.nix { })
        }/bin/amcrest2mqtt";
    };
  };
}
