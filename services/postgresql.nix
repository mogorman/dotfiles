{ config, lib, pkgs, ... }: {
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    dataDir = "/state/postgresql/${config.services.postgresql.package.psqlSchema}";
    ensureUsers = [{
      name = "hass";
      ensurePermissions = {
        "DATABASE hass" = "ALL PRIVILEGES";
      };
    }];
  };
}
