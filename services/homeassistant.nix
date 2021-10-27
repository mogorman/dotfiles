{ config, lib, pkgs, ... }:
{
services.home-assistant = {
  enable = true;
    package = (pkgs.unstable.home-assistant.override {
      extraPackages = py: with py; [ psycopg2 aiohttp-cors ];
    });
    config.recorder.db_url = "postgresql://@/hass";
  };
}
