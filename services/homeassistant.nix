{ config, lib, pkgs, ... }:
{
services.home-assistant = {
  enable = true;
    package = (pkgs.unstable.home-assistant.override {
      # pytestCheckPhase uses too much RAM and odyssey struggles with it
      doCheck = false;
      doInstallCheck = false;
      extraPackages = py: with py; [ psycopg2 aiohttp-cors ];
    });
    config.recorder.db_url = "postgresql://@/hass";
  };
}
